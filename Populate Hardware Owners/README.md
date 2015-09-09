#Hardware Owners
##Overview

This simple script updates hardware owners based on a CSV. The easiest way to generate this file would be to pull an export from Samanage and then modify the file as needed. The example file only includes the id, name and a column for asset owners in email format.

##How to use

Edit hardware_owners.rb by adding your Samanage API credentials to the "email" and "pass" variables, then enter the following command:
`
ruby hardware_owners.rb filename.csv
`
This will update the hardware owners and generate a log entry for any errors that occur.