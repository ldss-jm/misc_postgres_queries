#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + '856_bad_indicators_pt2.csv'

query = File.read(File.join(__dir__, '856_bad_indicators_pt2.sql'))

headers = %w[problem bnum coll title marc_ind1 marc_ind2
             link_type m856 $3 $x $y $z $u fixed]
Sierra::DB.query(query)
Sierra::DB.write_results(outfile, headers: headers, format: 'csv')

email_body = <<~BODY
  How-to:
  https://internal.lib.unc.edu/wikis/staff/index.php/MISC_856_maintenance_--_Check_for_links_with_indicator_problems#Second_report_and_individual_856_review

  Maintenance project folder:
  "G:\\TechServ\\e-resources cataloging\\Cleanup\\856_indicators"

  Stats:
  "G:\\TechServ\\ESM\\e-resources cataloging\\task_stats.xlsx"
BODY

email_address = ['cisrael@email.unc.edu', Sierra::DB.yield_email]
cc_address = Sierra::DB.yield_email

Sierra::DB.mail_results(outfile,
                        {from: Sierra::DB.yield_email,
                         to: email_address,
                         cc: cc_address,
                         subject: 'Review 856s with indicator problems',
                         body: email_body},
                        remove_file: false)
