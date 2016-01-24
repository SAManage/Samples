#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby hardware_owners.rb \"filename.csv\"" 
	abort
end

email = ""
pass = ""




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("id,name,owner\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|

xml_post = "<hardware><owner><email>#{row["owner"]}</email></owner></hardware>"
result = SamanageAPI.put("hardwares/#{row["id"]}.xml", email, pass, xml_post)

if result["code"] > 201
	puts "#{row["name"]} failed: #{result["code"]}\n"
	log = File.open(fname, "a+")
	log.write("#{row.to_s.chomp},#{result["code"]}\n")
	log.close
else
	puts "#{row["name"]} updated\n"
end

end