#Import Other Assets w/ Custom Fields
##Overview

This simple script creates Samanage assets based on a CSV source with custom fields.

##How to use
To use this script edit the the import_other_assets.rb file to match your Samanage user credentials:

```ruby
email = "email@company.com"
pass = "password"
```

Each row of the CSV will send a new user to Samanage as an XML object based on the template. In this example, each row has columns which are selected by row["Column Name"].

```ruby
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
```
To run the script simply enter `ruby import_other_assets.rb other_assets.csv` Any asset creation that is not successful will be logged into a local error file.
