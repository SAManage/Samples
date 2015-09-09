#Import Hardware w/ Custom Fields

The following scripts are provided by Samanage as examples and training purposes only and not designed to work in every use case without some modification to the script itself. These scripts are not supported by Samanage as part of your Samanage Master Subscription Agreement, however if you would like this script customized to support your use case, please contact us at API.Scripts@samanage.com for a personal quote.

##Overview

This simple script imports Hardware into Samanage based on a CSV data source.
Each row of the CSV will send a new user to Samanage as an XML object based on the [template](https://www.samanage.com/api/computers.html).
In this example, each row has columns which are selected by row["Column Name"].

```ruby
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
```

To run the script simply enter:

`ruby import_hardwares.rb computers.csv email password`

**email** and **password** correspond to your API credentials for Samanage.
Any asset creation that is not successful will be logged into a local error file. 
