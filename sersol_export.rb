load '../postgres_connect/connect.rb'

c = Connect.new

c.make_query('sersol_export.sql')
#c.write_results('mill_data.txt', format: 'tsv', include_headers: true)
c.write_results(
  '//ad.unc.edu/lib/departments/TechServ/ESM/e-resources cataloging/SerialsSolutions ebook MARC processing/data/mill_data.txt',
  format: 'tsv',
  include_headers: true
)