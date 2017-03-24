load '../postgres_connect/connect.rb'

def make_query(query_file, outfile)
  query = File.read(query_file)
  puts 'running query'
  results = run_query(query, @prod_cred)
  puts 'writing results'
  write_results(outfile, results)
end

make_query('773_field_group_tag.sql', '773_field_group_tag.results.txt')
