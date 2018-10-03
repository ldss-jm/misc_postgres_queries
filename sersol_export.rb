#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = '//ad.unc.edu/lib/departments/TechServ/ESM/e-resources cataloging/SerialsSolutions ebook MARC processing/data/'
outfile = outdir + 'mill_data.txt'

query = <<~SQL
  select distinct 'b' || rm.record_num || 'a' as "RECORD #(BIBLIO)"
                , ph.index_entry as "001"
                , (SELECT STRING_AGG(brl.location_code, ', ')
                    FROM sierra_view.bib_record_location brl
                    WHERE brl.bib_record_id = b.id
                    and brl.location_code != 'multi'
                  ) AS "LOCATION"
  from sierra_view.phrase_entry ph
  inner join sierra_view.bib_record b on b.id = ph.record_id
  inner join sierra_view.record_metadata rm on rm.id = b.id
  where (ph.index_tag || ph.index_entry) ~ '^oss(e|eb)[0-9]+$'
SQL

SierraDB.make_query(query)
SierraDB.write_results(
  outfile,
  format: 'tsv',
  include_headers: true
)
