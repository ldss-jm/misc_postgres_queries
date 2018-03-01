SELECT 'b' || rm.record_num || 'a' as bnum, v001.field_content as _001, b.bcode3,
   v.marc_tag, v.field_content
 FROM sierra_view.varfield v
 INNER JOIN sierra_view.bib_record b on b.record_id = v.record_id
   AND b.bcode3 not in ('d', 'n', 'c')
 INNER JOIN sierra_view.record_metadata rm on rm.id = b.id
 INNER JOIN sierra_view.varfield v001 on v001.record_id = v.record_id
   AND v001.marc_tag = '001'
   AND v001.field_content not ilike 'ss%'
 WHERE
   v.field_content ~ '&#?[a-z0-9]{2,25};'