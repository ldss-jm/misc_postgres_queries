#!/usr/bin/env ruby
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + 'mono_bibs_unsupp_holdings_endeca_display_probs.xlsx'


headers = ['bnum', 'cnum', 'problem_location', 'url']
SierraDB.make_query('mono_bibs_unsupp_holdings_endeca_display_probs.sql')
SierraDB.write_results(
  outfile,
  headers: headers,
  format: 'xlsx'
)

email_body = <<~EOL
  Report attached. These holdings records are unsuppressed and
  have no items attached. They are attached to bibs that display holdings in
  Endeca. This causes display problems.
EOL
email_address = SierraDB.yield_email

SierraDB.mail_results(
  outfile,
  mail_details = {:from => email_address,
                  :to => email_address,
                  :subject => 'Mono bibs w/unsuppressed holdings -' +
                              ' Endeca display problems',
                  :body => email_body},
  remove_file: true
)

