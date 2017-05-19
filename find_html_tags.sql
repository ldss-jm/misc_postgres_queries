select 'b' || rm.record_num || 'a' as bnum, v001.field_content as _001, v.marc_tag, v.field_content
from sierra_view.varfield v
inner join sierra_view.bib_record b on b.id = v.record_id
  and b.bcode3 not in ('d', 'c')
inner join sierra_view.record_metadata rm on rm.id = b.id
inner join sierra_view.varfield v001 on v001.record_id = b.id
  and v001.marc_tag = '001'
  and v001.field_content not ilike 'ss%'
where
  v.field_content ~ '<[/a-zA-Z]'
