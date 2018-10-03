#!/usr/bin/env ruby
require 'csv'
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + 'YYYY-MM-DD_html_tags.xlsx'


def detect_html(content)
  if (
    content.match(/<\/?[abipqu]>/) or
    content.match(/<\/?h[1-6]>/) or
    content.match(/<\/?div>/) or
    content.match(/<\/?br ?\/?>/) or
    content.match(/<\/?d[ltd]>/) or
    content.match(/<\/?em>/) or
    content.match(/<\/?font>/) or
    content.match(/<\/?l[hi]>/) or
    content.match(/<\/?[ou]l>/) or
    content.match(/<\/?pre>/) or
    content.match(/<\/?small>/) or
    content.match(/<\/?str[io][kn][eg]>/) or
    content.match(/<\/?su[bp]>/) or
    content.match(/<\/?t[dhrt]>/) or
    content.match(/<\/?body/) or
    content.match(/<\/?caption/) or
    content.match(/<\/?script/) or
    content.match(/<\/?span/) or
    content.match(/<\/?style/)
  )
    return true
  end
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

SierraDB.make_query(query)
html_problems = []
SierraDB.results.each do |record|
  content = record['field_content'].downcase
  if detect_html(content)
    html_problems << record
  end
end

html_problems.sort_by! { |x| x.values }
SierraDB.write_results(
  outfile,
  results: html_problems,
  headers: ['bnum', '_001', 'marc_tag', 'field_content'],
  format: 'csv'
)

# get a list of all things resembling tags in results
=begin
tags = []
results.each do |record|
  content = record['field_content']
  content.scan(/<[^ >]*/).each do |mtch|
    tags << mtch
  end
end
File.write('tags.txt', tags.sort.uniq.join("\n")
=end
