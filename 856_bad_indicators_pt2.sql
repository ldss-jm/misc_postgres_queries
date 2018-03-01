with recs as
(select 'b' || rm.record_num || 'a' as bnum,
   --b.bcode3,
(select STRING_AGG(v.field_content, ';')
   from sierra_view.varfield v
   where v.record_id = b.id
   and v.marc_tag = '773'
   and v.field_content like '%(online collection)%') as coll,
brp.best_title as title,
--v.marc_tag,
v.marc_ind1, v.marc_ind2,
case
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|uhttp' or v.field_content ~ '\|u//'
   then 'html'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|uftp'
   then 'ftp'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|utelnet'
   then 'telnet'
when replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') ~ '\|umailto'
   then 'email'
else null
end as link_type,
v.field_content as "m856",
(select STRING_AGG(sf.content, ';')
   from sierra_view.subfield sf
   where sf.varfield_id = v.id
   and sf.tag = '3') as "$3",
(select STRING_AGG(sf.content, ';')
   from sierra_view.subfield sf
   where sf.varfield_id = v.id
   and sf.tag = 'x') as "$x",
(select STRING_AGG(sf.content, ';')
   from sierra_view.subfield sf
   where sf.varfield_id = v.id
   and sf.tag = 'y') as "$y",
(select STRING_AGG(sf.content, ';')
   from sierra_view.subfield sf
   where sf.varfield_id = v.id
   and sf.tag = 'z') as "$z",
(select STRING_AGG(sf.content, ';')
   from sierra_view.subfield sf
   where sf.varfield_id = v.id
   and sf.tag = 'u') as "$u",
'' as fixed
from sierra_view.bib_record b
inner join sierra_view.record_metadata rm on rm.id = b.id
inner join sierra_view.bib_record_property brp on brp.bib_record_id = b.id
inner join sierra_view.varfield v on v.record_id = b.id
  and v.marc_tag = '856' and
(
     ( v.marc_ind1 = '0' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|umailto') or
     ( v.marc_ind1 = '1' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|uftp') or
     ( v.marc_ind1 = '2' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|utelnet') or
     ( v.marc_ind1 = '4' and replace(v.field_content, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|u(http|//)') or -- //www.unc.edu is a working url
			v.marc_ind1 not in ('0', '1', '2', '4') or 
       v.marc_ind2 not in ('0', '1', '2', '8') or
       v.marc_ind2 in ('1', '8') and exists (select * from sierra_view.varfield v where v.record_id = b.id and v.marc_tag = '773' and v.field_content ~ 'online collection')
)
where b.bcode3 not in ('d', 'n', 'c')
and not exists (select * from sierra_view.varfield v where v.record_id = b.id and v.marc_tag = '040' and v.field_content ~* 'GPO|MvI')
order by link_type, marc_ind1, coll, marc_ind2
)

select
concat_ws('; ',
case
when marc_ind1 = ''
  then 'no ind1'
when marc_ind1 not in ('0', '1', '2', '4')
  then 'weird ind1'
when ((marc_ind1 = '0' and replace(m856, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|umailto') or
     ( marc_ind1 = '1' and replace(m856, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|uftp') or
     ( marc_ind1 = '2' and replace(m856, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|utelnet') or
     ( marc_ind1 = '4' and replace(m856, 'http://libproxy.lib.unc.edu/login?url=', '') !~* '\|u(http|//)')
     and link_type is not null)
  then 'ind1-url mismatch'
end,
case
when marc_ind2 not in ('0', '1', '2', '8') or
     (marc_ind2 in ('1', '8') and coll is not null)
  then 'check ind2'
end,
case
when link_type is null
  then 'check $u and ind1'
end) as "problem_hints",
*
 from recs