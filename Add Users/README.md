#Import Users w/ Custom Fields
##Overview

This simple script creates Samanage users based on a CSV source.

##How to use
To use this script edit the the import_users.rb fileto match your Samanage user credentials:

```ruby
email = "email@company.com"
pass = "password"
```

Each row of the CSV will send a new user to Samanage as an XML object based on the template. In this example, each row has columns which are selected by row["Column Name"].

```ruby
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
```

To run the script simply enter ruby import_users.rb users.csv. Any user creation that is not successful will be logged into a local error file.
