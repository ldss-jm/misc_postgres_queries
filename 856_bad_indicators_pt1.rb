load '../postgres_connect/connect.rb'

c = Connect.new

outfile = '856_bad_indicators_pt1.xlsx'
headers = ['bnum', 'bcode3', 'coll', 'marc_tag', 'ind1', 'ind2', 'link_type', 'field_content']
c.make_query('856_bad_indicators_pt1.sql')
c.write_results(outfile,
              format: 'xlsx'
)
