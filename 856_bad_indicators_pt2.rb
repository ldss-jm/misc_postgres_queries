load '../postgres_connect/connect.rb'

c = Connect.new

outfile = '856_bad_indicators_pt2.xlsx'
#headers = ['bnum', 'bcode3', 'coll', 'marc_tag', 'ind1', 'ind2', 'link_type', 'field_content']
c.make_query('856_bad_indicators_pt2.sql')
c.write_results(outfile,
              format: 'xlsx'
)

email_body = <<-EOL
How-to:
https://internal.lib.unc.edu/wikis/staff/index.php/MISC_856_maintenance_--_Check_for_links_with_indicator_problems#Second_report_and_individual_856_review

Maintenance project folder: 
"G:\\TechServ\\e-resources cataloging\\Cleanup\\856_indicators"

Stats:
"G:\\TechServ\\ESM\\e-resources cataloging\\task_stats.xlsx"
EOL

email_address = 'cisrael@email.unc.edu'
cc_address = c.yield_email

c.mail_results(outfile,
            mail_details = {:from => cc_address,
                            :to => email_address,
                            :cc => cc_address,
                            :subject => 'Review 856s with indicator problems',
                            :body => email_body},
            remove_file: true
)