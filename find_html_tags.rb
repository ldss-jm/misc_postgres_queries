load '../postgres_connect/connect.rb'
require 'csv'

def detect_html(content)
  if (
    content.match(/<\/?[abipqu]>/) or
    content.match(/<\/?h[1-6]>/) or
    content.match(/<\/?div>/) or
    content.match(/<\/?br ?\/?>/) or
    content.match(/<\/?d[ltd]>/) or
    content.match(/<\/?em>/) or
    content.match(/<\/?font>/) or
    content.match(/<\/?l[hi]>/) or
    content.match(/<\/?[ou]l>/) or
    content.match(/<\/?pre>/) or
    content.match(/<\/?small>/) or
    content.match(/<\/?str[io][kn][eg]>/) or
    content.match(/<\/?su[bp]>/) or
    content.match(/<\/?t[dhrt]>/) or
    content.match(/<\/?body/) or
    content.match(/<\/?caption/) or
    content.match(/<\/?script/) or
    content.match(/<\/?span/) or
    content.match(/<\/?style/)
  )
    return true
  end
end

c = Connect.new
c.make_query('find_html_tags.sql')
html_problems = []
c.results.each do |record|
  content = record['field_content'].downcase
  if detect_html(content)
   html_problems << record
  end
end

html_problems.sort_by! { |x| x.values }
c.write_results('find_html_tags.results.txt',
              results: html_problems,
              headers: ['bnum', '_001', 'marc_tag', 'field_content'],
              format: 'tsv'
)

# get a list of all things resembling tags in results
=begin
tags = []
results.each do |record|
  content = record['field_content']
  content.scan(/<[^ >]*/).each do |mtch|
    tags << mtch
  end
end
File.write('tags.txt', tags.sort.uniq.join("\n")
=end
