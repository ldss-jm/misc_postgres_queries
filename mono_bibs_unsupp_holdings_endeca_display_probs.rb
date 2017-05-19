load '../postgres_connect/connect.rb'

c = Connect.new

outfile = 'mono_bibs_unsupp_holdings_endeca_display_probs.xlsx'
headers = ['bnum', 'cnum', 'problem_location', 'url']
c.make_query('mono_bibs_unsupp_holdings_endeca_display_probs.sql')
c.write_results(outfile,
              headers: headers,
              format: 'xlsx'
)




email_body = 'Report attached. These holdings records are unsuppressed and' +
' have no items attached. They are attached to bibs that display holdings in' +
' Endeca. This causes display problems.'
email_address = c.yield_email

c.mail_results(outfile,
            mail_details = {:from => email_address,
                            :to => email_address,
                            :subject => 'Mono bibs w/unsuppressed holdings -' +
                                        ' Endeca display problems',
                            :body => email_body},
            remove_file: true
)
  
