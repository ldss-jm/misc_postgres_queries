load '../postgres_connect/connect.rb'


outfile = 'mono_bibs_unsupp_holdings_endeca_display_probs.xlsx'
headers = ['bnum', 'cnum', 'problem_location', 'url']
results = make_query('mono_bibs_unsupp_holdings_endeca_display_probs.sql')
write_results(outfile,
              results,
              headers,
              'xlsx'
)




email_body = 'Report attached. These holdings records are unsuppressed and' +
' have no items attached. They are attached to bibs that display holdings in' +
' Endeca. This causes display problems.'
email_address = get_email_secret(@email_secret)

mail_results(outfile,
            mail_details = {:from => email_address,
                            :to => email_address,
                            :subject => 'Mono bibs w/unsuppressed holdings -' +
                                        ' Endeca display problems',
                            :body => email_body}
)
  
