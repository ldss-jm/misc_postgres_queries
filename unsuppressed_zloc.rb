#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"

# items
outfile = outdir + 'unsuppressed_zloc_items.csv'
query = <<~SQL
  select 'b'|| rm.record_num ||'a' as bnum, 'i' || rmi.record_num || 'a' as rnum, i.location_code, b.bcode1,
    'true' as "displays_in_catalog?"
  from sierra_view.item_record i
  inner join sierra_view.bib_record_item_record_link bil on bil.item_record_id = i.id
  inner join sierra_view.bib_record b on b.id = bil.bib_record_id and b.is_suppressed = 'f'
  inner join sierra_view.record_metadata rm on rm.id = b.id and rm.campus_code != 'ncip'
  inner join sierra_view.record_metadata rmi on rmi.id = i.id
  where i.is_suppressed = 'f'
  and (i.location_code = 'nozh' or (i.location_code ~ 'z$' and i.location_code not in ('uldaz', 'nohz')))
  order by i.location_code, b.bcode1
SQL
Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'csv', include_headers: true)

# holdings
outfile = outdir + 'unsuppressed_zloc_holdings.csv'
query = <<~SQL
  select 'b'|| rm.record_num ||'a' as bnum, 'c' || rmh.record_num || 'a' as rnum, hloc.location_code, b.bcode1,
  case
  when exists (select * from sierra_view.varfield v where v.record_id = h.id and (v.marc_tag ~ '86[678]' or (v.marc_tag = '852' and v.field_content ~ '\\|z'))) --double escape the pipe in ruby
  then 'true'
  else
   'false'
  end as "displays_in_catalog?"
    from sierra_view.holding_record h
    inner join sierra_view.bib_record_holding_record_link bhl on bhl.holding_record_id = h.id
    inner join sierra_view.bib_record b on b.id = bhl.bib_record_id and b.is_suppressed = 'f'
    inner join sierra_view.record_metadata rm on rm.id = b.id and rm.campus_code != 'ncip'
    inner join sierra_view.record_metadata rmh on rmh.id = h.id
    inner join sierra_view.holding_record_location hloc on hloc.holding_record_id = h.id
    where h.is_suppressed = 'f'
    and (hloc.location_code = 'nozh' or (hloc.location_code ~ 'z$' and hloc.location_code not in ('uldaz', 'nohz')))
    order by hloc.location_code, b.bcode1
SQL
Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'csv', include_headers: true)

# orders
outfile = outdir + 'unsuppressed_zloc_orders.csv'
query = <<~SQL
select 'b'|| rm.record_num ||'a' as bnum, 'o' || rmo.record_num || 'a' as rnum, cmf.location_code, b.bcode1,
case
when exists (select * from sierra_view.item_record i inner join sierra_view.bib_record_item_record_link bil on bil.item_record_id = i.id where bil.bib_record_id = b.id and i.is_suppressed = 'f')
then 'false'
else
 'maybe'
end as "displays_in_catalog?"
  from sierra_view.order_record o
  inner join sierra_view.bib_record_order_record_link bol on bol.order_record_id = o.id
  inner join sierra_view.bib_record b on b.id = bol.bib_record_id and b.is_suppressed = 'f'
  inner join sierra_view.record_metadata rm on rm.id = b.id and rm.campus_code != 'ncip'
  inner join sierra_view.record_metadata rmo on rmo.id = o.id
  inner join sierra_view.order_record_cmf cmf on cmf.order_record_id = o.id
  where o.is_suppressed = 'f'
  and (cmf.location_code = 'nozh' or (cmf.location_code ~ 'z$' and cmf.location_code not in ('uldaz', 'nohz')))
  order by cmf.location_code, b.bcode1
SQL
Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'csv', include_headers: true)
