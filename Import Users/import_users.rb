#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby import_users.rb \"filename.csv\"" 
	abort
end

email = "email@company.com"
pass = "password"




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("email,name,title,phone,mobile phone,language,site,department,reports to,role,employee id,nickname,error\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|
xml_post = "<user>
<name>#{row["name"]}</name>
<email>#{row["email"]}</email>
<title>#{row["title"]}</title>
<phone>#{row["phone"]}</phone>
<mobile_phone>#{row["mobile phone"]}</mobile_phone>
<language>#{row["language"]}</language>
<site><name>#{row["site"]}</name></site>
<department><name>#{row["department"]}</name></department>
<reports_to><email>#{row["reports to"]}</email></reports_to>
<role><name>#{row["role"]}</name></role>
<custom_fields_values>
	<custom_fields_value>
		<name>Employee ID</name>
		<value>#{row["employee id"]}</value>
	</custom_fields_value>
	<custom_fields_value>
		<name>Nickname</name>
		<value>#{row["nickname"]}</value>
	</custom_fields_value>
</custom_fields_values>
</user>"


result = SamanageAPI.post('users.xml', email, pass, xml_post)
if result["code"] > 201
	puts "#{row["name"]} failed: #{result["code"]}\n#{result["xml"]}\n"
	log = File.open(fname, "a+")
	log.write("#{row.to_s.chomp},#{result["code"]}\n")
	log.close
else
	puts "#{row["name"]} created\n"
end

end