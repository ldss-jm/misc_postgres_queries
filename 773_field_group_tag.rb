#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + '773_field_group_tag.results.txt'

query = <<~SQL
  select *
  from sierra_view.varfield v
  inner join sierra_view.bib_record b on b.id = v.record_id
  where marc_tag = '773'
    and varfield_type_code != 'w'
SQL

Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'tsv', include_headers: false)
