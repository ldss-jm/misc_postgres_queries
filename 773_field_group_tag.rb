#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + '773_field_group_tag.results.txt'

query = <<~SQL
  select *
  from sierra_view.varfield_view
  where marc_tag = '773'
    and record_type_code = 'b'
    and varfield_type_code != 'w'
SQL

SierraDB.make_query(query)
SierraDB.write_results(outfile, format: 'tsv', include_headers: false)
