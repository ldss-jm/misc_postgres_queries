load '../postgres_connect/connect.rb'

c = Connect.new

outfile = '856_repeated_subfield_u.xlsx'
headers = ['bnum', 'ind1', 'ind2', 'field_content']
c.make_query('856_repeated_subfield_u.sql')
c.write_results(outfile,
              headers: headers,
              format: 'xlsx'
)