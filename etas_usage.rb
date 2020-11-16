#!/usr/bin/env ruby
require 'sierra_postgres_utilities'
require 'marc_to_argot'

outdir = "#{__dir__}/output/"
outfile = outdir + 'hathi_etas_bibs.csv'

class LCCHierarchy
  attr_reader :callnum

  def initialize(callnum)
    @callnum = callnum
  end

  def find_path(callnum)
    MarcToArgot::CallNumbers::LCC.find_path(callnum)
  end

  def hierarchy
    return [] unless callnum
    find_path(callnum.downcase)
  end

  def hier_data
    return @hier_data if @hier_data

    clean_hier = hierarchy.map { |x| clean_hier_elem(x) }
    @hier_data = {
      full: {
        range: clean_hier.map { |x| x[:range] }.compact.last,
        label: clean_hier.map { |x| x[:label] }.compact.join(' > ')
      },
      hier1: {
        range: clean_hier.first&.fetch(:range),
        label: clean_hier.first&.fetch(:label)
      },
      hier2: {
        range: clean_hier[1]&.fetch(:range) || clean_hier[0]&.fetch(:range),
        label: clean_hier[0..1].map { |x| x[:label] }.compact.join(' > ')
      }
    }
  end

  def hier1_str
    return unless hier_data[:hier1]
    "#{hier_data[:hier1][:range]} #{hier_data[:hier1][:label]}"
  end

  def hier2_str
    return unless hier_data[:hier2]
    "#{hier_data[:hier2][:range]} #{hier_data[:hier2][:label]}"
  end

  def hier_str(n)
    return unless n < 3

    "#{hier_data["hier#{n}".to_sym][:range]} #{hier_data["hier#{n}".to_sym][:label]}"
  end

  def clean_hier_elem(elem)
    # PT2603.R397 Z585 2002
    # KF3775.A29 U572
    m = elem.match(/^(?<range>[A-Z]+[0-9\.]*( - )?([A-Z]+[0-9\.]+)?)( ?(?<label>.*$))?/)
    return {} unless m
    range = m[:range]
    label = m[:label] unless m[:label].empty?
    {range: range, label: label}
  end
end

class ETASBib
  attr_reader :record

  def self.query
    query = <<~SQL
      select distinct on (rm.record_num)
        'b'||rm.record_num as bnum
      , v001.field_content as oclcnum
      , case
        when brp.bib_level_code in ('b', 'i', 's')
        then 'serial'
        else 'mono'
        end as serial_or_mono
      , brp.best_title as title
      , brp.publish_year as pubdate
      , regexp_replace(regexp_replace(vpub.field_content,'.*\\|b',''),'\\|.*','') as publisher --double escape the pipe in ruby, single escape in sql
      , (select regexp_replace(vc.field_content,'\\|.','','g') --double escape the pipe in ruby, single escape in sql
          from sierra_view.varfield vc
          inner join sierra_view.bib_record_item_record_link bil on bil.bib_record_id = rm.id
          inner join sierra_view.item_record i on i.id = vc.record_id
          where vc.record_id = bil.item_record_id and vc.varfield_type_code = 'c'
            and vc.marc_tag in ('090', '050', '060', '096')
          limit 1) as callnum
      from sierra_view.varfield v
      inner join sierra_view.record_metadata rm on rm.id = v.record_id
      inner join sierra_view.bib_record_property brp on brp.bib_record_id = rm.id
      left join sierra_view.varfield v001 on v001.record_id = v.record_id
        and v001.marc_tag = '001'
      left join sierra_view.varfield vpub on vpub.record_id = rm.id
        and (vpub.marc_tag = '260' or (vpub.marc_tag = '264' and vpub.marc_ind2 = '1'))
      where v.marc_tag = '856'
        and (v.field_content ~ 'ETAS' or v.field_content ~ 'Wanda delete')
    SQL
  end

  def initialize(sql_record = {})
    @record = sql_record
  end

  def publisher
    record[:publisher]&.sub(/[ ,\]\/]+$/,'')
  end

  def callnum
    record[:callnum]
  end

  def hierarchy
    LCCHierarchy.new(callnum)
  end

  def output
    {
      bnum: record[:bnum],
      oclcnum: record[:oclcnum],
      serial_or_mono: record[:serial_or_mono],
      title: record[:title],
      pubdate: record[:pubdate],
      publisher: publisher,
      lc_callnum: callnum,
      lc_hier1: hierarchy.hier1_str,
      lc_hier2: hierarchy.hier2_str
    }
  end
end

Sierra::DB.query(ETASBib.query)

CSV.open(outfile, 'w') do |csv|
  csv << ETASBib.new.output.keys
  Sierra::DB.results.each { |record| csv << ETASBib.new(record).output.values }
end
