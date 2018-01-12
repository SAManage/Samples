# Samanage Warranty Sync Script


This simple script allows you to sync warranty information into Samanage using ruby.

## Requirements
- [Ruby 2.3+]
- [Samanage Gem](https://rubygems.org/gems/samanage) for Ruby
- CSV of Warranty information (Use our attached template!)
- Native Samanage API Token (single sign on credentials are not supported)
	

## Instructions
- Compile your warranty information into the above **warranties.csv** template
	- US datacenter: ```ruby sync_warranties.rb warranties.csv API_TOKEN```
	- EU datacenter: ```ruby sync_warranties.rb warranties.csv API_TOKEN eu```


### Notes
- Dates are parsed explicitly using the format 01/31/2000. If you wish to use a different date format this can be modified here:

- All warranties included in the CSV will be uploaded. Please exclude any expired warranties if you do not wish to import them.