#!/usr/bin/env ruby

# Identifies bibs with missing titles that present as having 245s like:
#   `|a< >.`

require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + 'missing_titles_brackets_only.csv'

query = <<~SQL
  select
    'b' || rm.record_num || 'a' AS bnum,
    v.marc_tag || ' ' || COALESCE(nullif(v.marc_ind1, ' '), '_') || ' ' || COALESCE(nullif(v.marc_ind2, ' '), '_') || ' ' || replace(v.field_content, '|', '$') AS data
  from sierra_view.varfield v
  inner join sierra_view.bib_record b on b.id = v.record_id
    and b.cataloging_date_gmt IS NOT NULL
    and b.is_suppressed = 'f'
  inner join sierra_view.record_metadata rm on rm.id = v.record_id
  where v.marc_tag = '245'
    and v.field_content ~ '\\|a<\s?>' --double escape the pipes w/ ruby
SQL

Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'csv')

email_body = <<~BODY
  See:
  https://internal.lib.unc.edu/wikis/staff/index.php/DATA_Missing_titles/brackets_only
BODY

email_address = 'cisrael@email.unc.edu'
cc_address = Sierra::DB.yield_email

Sierra::DB.mail_results(outfile,
                        {from: Sierra::DB.yield_email,
                         to: email_address,
                         cc: cc_address,
                         subject: 'Review missing titles / brackets only',
                         body: email_body},
                        remove_file: false)
