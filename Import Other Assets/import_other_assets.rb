require 'csv'
require 'rubygems'
require_relative 'SamanageAPI.rb'

unless ARGV[0]
	puts "To run this script please enter a filename: \n\tEx: 'ruby import_users.rb \"filename.csv\"" 
	abort
end

email = "email@company.com"
pass = "Password"




fname = "Error Log - #{Time.now.strftime("%F - %H.%M")}.csv"
puts fname

log = File.open(fname, "w+")
log.write("Name,Asset ID,Status,Asset Type,Description,IP,Manufacturer,Model,Serial Number,Owner,User,Site,Department,Cost,Purchased From\n")
log.close


CSV.foreach(ARGV[0], :headers => true) do |row|
xml_post = "<other_asset>
<name>#{row["Name"]}</name>
<asset_id>#{row["Asset ID"]}</asset_id>
<status><name>#{row["Status"]}</name></status>
<asset_type><name>#{row["Asset Type"]}</name></asset_type>
<description>#{row["Description"]}</description>
<ip>#{row["IP"]}</ip>
<manufacturer>#{row["Manufacturer"]}</manufacturer>
<model>#{row["Model"]}</model>
<serial_number>#{row["Serial Number"]}</serial_number>
<owner><email>#{row["Owner"]}</email></owner>
<user><email>#{row["User"]}</email></user>
<site><name>#{row["Site"]}</name> </site>
<department><name>#{row["Department"]}</name></department>
<custom_fields_values>
	<custom_fields_value>
		<name>Cost</name>
		<value>#{row["Cost"]}</value>
	</custom_fields_value>
	<custom_fields_value>
		<name>Purchased From</name>
		<value>#{row["Purchased From"]}</value>
	</custom_fields_value>
</custom_fields_values>
</other_asset>"

puts xml_post

result = SamanageAPI.post('other_assets.xml', email, pass, xml_post)
if result["code"] > 201
	puts "#{row["name"]} failed: #{result["code"]}\n#{result["xml"]}\n"
	log = File.open(fname, "a+")
	log.write("#{row.to_s.chomp},#{result["code"]}\n")
	log.close
else
	puts "#{row["name"]} created\n"
end

end
