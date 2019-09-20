#!/usr/bin/env ruby
require 'csv'
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + 'YYYY-MM-DD_html_tags.csv'

TAG_PATTERNS = [
  /<\/?[abipqu]>/,
  /<\/?h[1-6]>/,
  /<\/?div>/,
  /<\/?br ?\/?>/,
  /<\/?d[ltd]>/,
  /<\/?em>/,
  /<\/?font>/,
  /<\/?l[hi]>/,
  /<\/?[ou]l>/,
  /<\/?pre>/,
  /<\/?small>/,
  /<\/?str[io][kn][eg]>/,
  /<\/?su[bp]>/,
  /<\/?t[dhrt]>/,
  /<\/?body/,
  /<\/?caption/,
  /<\/?script/,
  /<\/?span/,
  /<\/?style/
]
def detect_html(content)
  TAG_PATTERNS.each { |regexp| return true if content.match(regexp) }
end

query = <<~SQL
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
SQL

Sierra::DB.query(query)
html_problems = []
Sierra::DB.results.each do |record|
  content = record['field_content'].downcase
  html_problems << record if detect_html(content)
end

html_problems.sort_by! { |x| x.values }
Sierra::DB.write_results(
  outfile,
  results: html_problems,
  format: 'csv'
)
