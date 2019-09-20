#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + 'iolc_hathitrust.csv'

query = <<~SQL
  select distinct 'b' || rm.record_num || 'a' as bnum
  from sierra_view.phrase_entry phe
  inner join sierra_view.bib_record_item_record_link bil on bil.item_record_id = phe.record_id
  inner join sierra_view.record_metadata rm on rm.id = bil.bib_record_id
  where phe.index_tag || phe.index_entry ~ '^eiolc'
SQL

Sierra::DB.query(query)

ht_oclc = File.read('hathi_oclcnums.txt').split("\n")
results = []
Sierra::DB.results.values.flatten.each do |bnum|
  bib = Sierra::Record.get(bnum)
  oclcnum = bib.oclcnum
  oclc_in_ht = ht_oclc.bsearch { |ht| oclcnum <=> ht } ? 'yes' : 'no'
  results << {
    callno: bib.items&.
                map { |i| i.callnos&.first }&.
                select { |c| c =~ /^IOLC/i }&.
                first,
    oclc: bib.oclcnum,
    oclc_in_ht: oclc_in_ht,
    bnum: bib.bnum
  }
end

results.sort_by! { |b| b[:callno] }
Sierra::DB.write_results(
  outfile,
  results: results,
  format: 'csv',
  headers: ['callno', 'oclcnum', 'oclc_in_ht?', 'bnum']
)
