#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby import_departments.rb \"filename.csv\"" 
	abort
end

email = ""
pass = ""




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("name,description,error\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|
xml_post = "<department>
<name>#{row["Department Name"]}</name>
<description>#{row["Description"]}</description>
</department>"

result = SamanageAPI.post('departments.xml', email, pass, xml_post)
if result["code"] > 201
	puts "#{row["Department Name"]} failed: #{result["code"]}\n#{result["xml"]}\n"
	log = File.open(fname, "a+")
	log.write("#{row.to_s.chomp},#{result["code"]}\n")
	log.close
else
	puts "#{row["Department Name"]} created\n"
end

end