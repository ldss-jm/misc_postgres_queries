#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + '856_repeated_subfield_u.xlsx'

query = <<~SQL
  SELECT 'b' || rm.record_num || 'a' AS bnum,
  v.marc_ind1,
  v.marc_ind2,
  v.field_content
  FROM   sierra_view.varfield v
  INNER JOIN sierra_view.bib_record br on br.id = v.record_id
  INNER JOIN sierra_view.record_metadata rm on rm.id = br.id
  WHERE  v.marc_tag = '856'
  AND v.field_content ~ '\|u.*\|u'
SQL

headers = ['bnum', 'ind1', 'ind2', 'field_content']
SierraDB.make_query(query)
SierraDB.write_results(
  outfile,
  headers: headers,
  format: 'xlsx'
)
