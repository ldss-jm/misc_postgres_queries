load '../postgres_connect/connect.rb'

headers = ['bnum', 'cnum', 'holdings_loc']
results = make_query('unsupp_bib_holdings_no_unsupp_items.sql')
write_results('unsupp_bib_holdings_no_unsupp_items.results.csv',
              results,
              headers,
              csv=true
)
