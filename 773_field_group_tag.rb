load '../postgres_connect/connect.rb'

c = Connect.new

c.make_query('773_field_group_tag.sql')
c.write_results('773_field_group_tag.results.txt', format: 'tsv')
