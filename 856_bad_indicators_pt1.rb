#!/usr/bin/env ruby
require 'sierra_postgres_utilities'

outdir = "#{__dir__}/output/"
outfile = outdir + '856_bad_indicators_pt1.csv'

query = File.read(File.join(__dir__, '856_bad_indicators_pt1.sql'))

Sierra::DB.query(query)
Sierra::DB.write_results(outfile, format: 'csv')
