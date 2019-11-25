#!/usr/bin/env ruby

require 'docopt'
require 'sierra_postgres_utilities'

thisfile = File.basename(__FILE__)

doc = <<~DOCOPT
  For a newline-delimited file of 001 values, returns a newline-delimited
  file of Sierra bib record numbers.

  001 values with 0 matches or with more than 1 matches are printed to screen
  with a message, rather than being written to file.

  Usage:
    #{thisfile} INPATH OUTPATH

  Arguments:
    INPATH        Input file or directory
    OUTPATH       Output is written to this directory.

  Options:
    -h --help             Show this help text.
DOCOPT

args =
  begin
    Docopt.docopt(doc)
  rescue Docopt::Exit => e
    puts e.message
    abort
  end

filename = args['INPATH']

notfounds = []
multiple_matches = []
File.open(args['OUTPATH'], 'w') do |ofile|
  File.readlines(filename).each do |line|
    results = Sierra::Search.phrase_search('o', line.rstrip).to_a
    if results.nil? || results.empty?
      notfounds << line.strip
    elsif results.length > 1
      multiple_matches << line.strip
    else
      ofile << "#{results.first.bnum}\n"
    end
  end
end

unless notfounds.empty?
  puts 'Each of these 001s were not found:'
  puts notfounds.join("\n")
end
unless multiple_matches.empty?
  puts 'Each of these 001s had multiple matches:'
  puts notfounds.join("\n")
end
