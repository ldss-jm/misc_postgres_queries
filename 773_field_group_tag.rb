load '../postgres_connect/connect.rb'

results = make_query('773_field_group_tag.sql')
write_results('773_field_group_tag.results.txt', results, :tsv)
