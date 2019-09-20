#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + 'spr_data.txt'

query = <<~SQL
  SELECT 'b' || rm.record_num || 'a' as bnum,
    (select STRING_AGG(v.field_content, ';')
       from sierra_view.varfield v
       where v.record_id = rm.id
       and v.marc_tag = '001') as m001,
    (select STRING_AGG(sf.content, ';')
       from sierra_view.subfield sf
       where sf.record_id = rm.id
       and sf.marc_tag = '856'
       and sf.tag = 'u') as "856|u",
    (select STRING_AGG(sf.content, ';')
       from sierra_view.subfield sf
       where sf.record_id = rm.id
       and sf.marc_tag = '956'
       and sf.tag = 'u') as "956|u"
  FROM sierra_view.bib_record b
  INNER JOIN sierra_view.varfield v on v.record_id = b.id
  INNER JOIN sierra_view.record_metadata rm on rm.id = b.id
  WHERE v.marc_tag = '773'
    and v.field_content ilike '%|tSpringer e-books (online collection)%'
SQL

Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'tsv', include_headers: true)

Dir.chdir(outdir)
load "../../Cataloging_Scripts/springer_dedupe_on_urls.rb"
