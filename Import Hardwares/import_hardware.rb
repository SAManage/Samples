require 'csv'
require 'rubygems'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby import_users.rb \"filename.csv\"" 
	abort
end

email = ARGV[1]
pass = ARGV[2]




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("Name,Manufacturer,Serial Number,Model,Category,Site,Department,ip,Status,tag,technical contact,Owner,Insurance,Refresh Date\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|
xml_post = "<hardware>
<name>#{row["Name"]}</name>
<bio>
	<manufacturer>#{row["Manufacturer"]}</manufacturer>
	<ssn>#{row["Serial Number"]}</ssn>
	<model>#{row["Model"]}</model>
</bio>
<category><name>#{row["Category"]}</name></category>
<site><name>#{row["Site"]}</name> </site>
<department><name>#{row["Department"]}</name></department>
<ip>#{row["ip"]}</ip>
<status><name>#{row["Status"]}</name></status>
<tag>#{row["tag"]}</tag>
<technical_contact><email>#{row["technical contact"]}</email></technical_contact>
<owner><email>#{row["Owner"]}</email></owner>
<custom_fields_values>
	<custom_fields_value>
		<name>Insurance</name>
		<value>#{row["Insurance"]}</value>
	</custom_fields_value>
	<custom_fields_value>
		<name>Refresh Date</name>
		<value>#{row["Refresh Date"]}</value>
	</custom_fields_value>
</custom_fields_values>
</hardware>"

# puts xml_post

result = SamanageAPI.post('hardwares.xml', email, pass, xml_post)
if result["code"] > 201
	puts "#{row["Name"]} failed: #{result["code"]}\n#{result["xml"]}\n"
	log = File.open(fname, "a+")
	log.write("#{row.to_s.chomp},#{result["code"]}\n")
	log.close
else
	puts "#{row["Name"]} created\n"
end

end