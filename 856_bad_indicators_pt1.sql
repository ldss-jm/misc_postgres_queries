select 'b' || rm.record_num || 'a' as bnum, b.bcode3,
(select STRING_AGG(v.field_content, ';')
   from sierra_view.varfield v
   where v.record_id = b.id
   and v.marc_tag = '773'
   and v.field_content like '%(online collection)%') as coll,
v.marc_tag, v.marc_ind1 as ind1, v.marc_ind2 as ind2,
case
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|uhttp'
   then 'html'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|uftp'
   then 'ftp'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|utelnet'
   then 'telnet'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|umailto'
   then 'email'
else null
end as link_type,
v.field_content as "field_content"

from sierra_view.bib_record b
inner join sierra_view.record_metadata rm on rm.id = b.id
inner join sierra_view.varfield v on v.record_id = b.id
  and v.marc_tag = '856' and
(
     ( v.marc_ind1 = '0' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|umailto') or
     ( v.marc_ind1 = '1' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|uftp') or
     ( v.marc_ind1 = '2' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|utelnet') or
     ( v.marc_ind1 = '4' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|u(http|//)') or -- //www.unc.edu is a working url
			v.marc_ind1 not in ('0', '1', '2', '4')
)
where b.bcode3 not in ('d', 'n', 'c')
and not exists (select * from sierra_view.varfield v where v.record_id = b.id and v.marc_tag = '040' and v.field_content ~* 'GPO|MvI')
order by link_type, marc_ind1, coll, marc_ind2
