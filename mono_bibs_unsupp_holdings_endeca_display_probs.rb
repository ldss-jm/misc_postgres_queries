#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + 'mono_bibs_unsupp_holdings_endeca_display_probs.csv'


headers = ['bnum', 'cnum', 'problem_location', 'url']

query = File.read(File.join(__dir__, 'mono_bibs_unsupp_holdings_endeca_display_probs.sql'))

Sierra::DB.query(query)
Sierra::DB.write_results(
  outfile,
  headers: headers,
  format: 'csv'
)

email_body = <<~BODY
  Report attached. These holdings records are unsuppressed and
  have no items attached. They are attached to bibs that display holdings in
  Endeca. This causes display problems.
  BODY
email_address = Sierra::DB.yield_email

Sierra::DB.mail_results(
  outfile,
  mail_details = {:from => email_address,
                  :to => email_address,
                  :subject => 'Mono bibs w/unsuppressed holdings -' +
                              ' Endeca display problems',
                  :body => email_body},
  remove_file: true
)

