#!/usr/bin/env ruby
require 'fileutils'
require 'csv'
require_relative '../sierra-postgres-utilities/lib/sierra_postgres_utilities.rb'

outdir = "#{__dir__}/output/"
outfile = outdir + '773_field_group_tag.results.txt'

delete_docid_file = outdir + 'ebc_subs_deletions.docid'
delete_txt_file = outdir + 'ebc_subs_deletions.txt'
adds_file = outdir + 'ebc_subs_adds.txt'

# Takes input:
#   live Sierra data based on NCLive subs 773
#   Proquest subs title list -
#     from ProQuest LibCentral. See Staff Wiki
#      name as: #{outdir}/ebc_subs.csv
#
# Yields:
#   ebc_subs_deletions.txt
#     bnums of records in Sierra but not title list
#   ebc_subs_adds.txt
#     EBC Doc IDs (with no EBC or sub affixes) of records on title list
#     but not in Sierra
#
#

query = <<-SQL
  select 'b' || rm.record_num || 'a' as bnum, v001.field_content, b.bcode3
  from sierra_view.bib_record b
  inner join sierra_view.record_metadata rm on rm.id = b.id
  inner join sierra_view.varfield v001 on v001.record_id = b.id and v001.marc_tag = '001'
  inner join sierra_view.varfield v on v.record_id = b.id and v.marc_tag = '773'
    and v.field_content = '|tProQuest Ebook Central (online collection). NCLIVE subscription ebooks'
SQL

SierraDB.make_query(query)

m001_bnum_map = {}
m001s = SierraDB.results.entries.dup
m001s.each { |r| m001_bnum_map[r['field_content']] = r['bnum']}

m001s.map! { |rec| rec['field_content'].gsub(/^EBC/, '').gsub(/sub$/, '')}

proquest_list = []
pq_titlelist = File.open("#{outdir}ebc_subs.csv", 'r:bom|utf-8')
pq_titlelist.each_line do |line|
  m = line.match(/"([0-9]+)/)
  proquest_list << m[1] if m
end
proquest_list.sort!
m001s.sort!
adds = proquest_list - m001s
deletes = m001s - proquest_list
delete_bnums = deletes.map { |m001| m001_bnum_map["EBC" + m001 + "sub"] }

File.write(delete_docid_file, deletes.join("\n"))
File.write(delete_txt_file, delete_bnums.join("\n"))
File.write(adds_file, adds.join("\n"))
pq_titlelist.close
FileUtils.mv("#{outdir}ebc_subs.csv", "#{outdir}ebc_subs_prev.csv")

blah = []
CSV.foreach("#{outdir}ebc_subs_prev.csv", headers: true,
            quote_char: "\x00") do |rec|
  blah << rec
end
