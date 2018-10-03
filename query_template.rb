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
  limit 1
SQL
# or: query = "#{__dir__}/query_file.sql"

SierraDB.make_query(query)
# write to tsv
SierraDB.write_results(outfile, format: 'tsv', include_headers: false)
# write to xlsx (requires windows)
SierraDB.write_results(outfile, format: 'xlsx')

# send as attachment
email_body = <<-EOL
How-to:
https://internal.lib.unc.edu/wikis/staff/index.php/MISC_856_maintenance_--_Check_for_links_with_indicator_problems#Second_report_and_individual_856_review

Maintenance project folder:
"G:\\TechServ\\e-resources cataloging\\Cleanup\\856_indicators"

Stats:
"G:\\TechServ\\ESM\\e-resources cataloging\\task_stats.xlsx"
EOL

email_address = 'eres_cat@email.unc.edu'
cc_address = SierraDB.yield_email

SierraDB.mail_results(outfile,
            mail_details = {:from => cc_address,
                            :to => email_address,
                            :cc => cc_address,
                            :subject => 'Review 856s with indicator problems',
                            :body => email_body},
            remove_file: true
)
