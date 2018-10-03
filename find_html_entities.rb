#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + 'records_to_process.xlsx'

query = <<~SQL
  SELECT 'b' || rm.record_num || 'a' as bnum, v001.field_content as _001, b.bcode3,
    v.marc_tag, v.field_content
  FROM sierra_view.varfield v
  INNER JOIN sierra_view.bib_record b on b.record_id = v.record_id
    AND b.bcode3 not in ('d', 'n', 'c')
  INNER JOIN sierra_view.record_metadata rm on rm.id = b.id
  INNER JOIN sierra_view.varfield v001 on v001.record_id = v.record_id
    AND v001.marc_tag = '001'
    AND v001.field_content not ilike 'ss%'
  WHERE
    v.field_content ~ '&#?[a-z0-9]{2,25};'
SQL

SierraDB.make_query(query)
headers = ['bnum', '_001', 'bcode3', 'marc_tag', 'field_content']
SierraDB.write_results(
  outfile,
  headers: headers,
  format: 'xlsx'
)

email_body = 'Report attached. These are records containing (potential) html entities'
email_address = SierraDB.yield_email

SierraDB.mail_results(
  outfile,
  mail_details = {:from => email_address,
                  :to => email_address,
                  :subject => 'Report: html entity cleanup',
                  :body => email_body},
  remove_file: true
)
