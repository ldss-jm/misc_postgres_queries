#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + '856_bad_indicators_pt1.xlsx'

query = "#{__dir__}/query_file.sql"

headers = ['bnum', 'bcode3', 'coll', 'marc_tag', 'ind1', 'ind2', 'link_type', 'field_content']
SierraDB.make_query(query)
SierraDB.write_results(outfile, format: 'xlsx')
