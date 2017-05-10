#!/usr/bin/env ruby

require 'csv'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby import_sites.rb \"filename.csv\"" 
	abort
end

email = ""
pass = ""




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("Site Name,Location,Description,Time zone,Language,Business record ID,error\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|
  xml_post = "<site>
  <name>#{row["Site Name"]}</name>
  <location>#{row["Location"]}</location>
  <description>#{row["Description"]}</description>
  <time-zone>#{row["Time zone"].gsub("&","&amp;")}</time-zone>
  <language>#{row["Language"]}</language>
  <business-record-id>#{row["Business record ID"]}</business-record-id>
  </site>"
  puts xml_post

  result = SamanageAPI.post('sites.xml', email, pass, xml_post)
  if result["code"] > 201
  	puts "#{row["Site Name"]} failed: #{result["code"]}\n#{result["xml"]}\n"
  	log = File.open(fname, "a+")
  	log.write("#{row.to_s.chomp},#{result["code"]}\n")
  	log.close
  else
  	puts "#{row["Site Name"]} created\n"
  end
  
end
