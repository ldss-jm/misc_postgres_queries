#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + 'iolc_hathitrust.xlsx'

query = <<~SQL
  select distinct 'b' || rm.record_num || 'a' as bnum
  from sierra_view.phrase_entry phe
  inner join sierra_view.bib_record_item_record_link bil on bil.item_record_id = phe.record_id
  inner join sierra_view.record_metadata rm on rm.id = bil.bib_record_id
  where phe.index_tag || phe.index_entry ~ '^eiolc'
SQL

SierraDB.make_query(query)

ht_oclc = File.read('hathi_oclcnums.txt').split("\n")
results = []
SierraDB.results.values.flatten.each do |bnum|
  bib = SierraBib.new(bnum)
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
SierraDB.write_results(
  outfile,
  results: results,
  format: 'xlsx',
  headers: ['callno', 'oclcnum', 'oclc_in_ht?', 'bnum']
)
