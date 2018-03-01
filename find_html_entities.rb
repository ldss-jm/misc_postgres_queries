load '../postgres_connect/connect.rb'

c = Connect.new

outfile = 'records_to_process.xlsx'
headers = ['bnum', '_001', 'bcode3', 'marc_tag', 'field_content']
c.make_query('find_html_entities.sql')
c.write_results(outfile,
              headers: headers,
              format: 'xlsx'
)




email_body = 'Report attached. These are records containing (potential) html entities'
email_address = c.yield_email

c.mail_results(outfile,
            mail_details = {:from => email_address,
                            :to => email_address,
                            :subject => 'Report: html entity cleanup',
                            :body => email_body},
            remove_file: true
)