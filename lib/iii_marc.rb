#!/usr/bin/env ruby
require 'enhanced_marc'
require 'htmlentities'
require 'iconv'
require 'patron'

require 'iii_marc/utils'
require 'iii_marc/constants'
require 'iii_marc/datafield'
require 'iii_marc/record'
require 'iii_marc/reader'

if $0 == __FILE__
  reader = MARC::IIIReader.new 'http://opac.uthsc.edu'
  
  if ARGV.length == 1    
    record = reader.get_record ARGV[0]
    if record
      puts '*'*60
      puts "Bib #: #{record.bibnum}"
      puts "Check digit: #{record.check_digit}"
      puts "Call #: #{record.call_number}"
      puts "Title: #{record.title}"
      puts "ISSN(s): #{record.issn.join(', ')}" if record.issn
      puts "ISBN(s): #{record.isbn.join(', ')}" if record.isbn
      puts "Author: #{record.author}"
      puts "Author dates: #{record.author_dates}"
      puts "Uniform title: #{record.uniform_title}"
      puts '-'*60
      puts record      
      puts '*'*60
    end
  elsif ARGV.length == 2    
    start = Time.now
    records = reader.crawl_records(ARGV[0], ARGV[1])
    
    elapsed = Time.now - start
    per_sec = records.length/elapsed
    puts "Total records found: #{records.length}"
    puts "Total time: #{elapsed} seconds"
    puts "Records per second: #{per_sec}"
  else
    record = reader.get_record 'b1069566'    
    puts 'b1069566'
    puts record
  end
end