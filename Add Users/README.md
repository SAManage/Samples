#Import Users w/ Custom Fields
##Overview

This simple script creates Samanage users based on a CSV source.

##How to use
Edit import_users.rb by adding your Samanage API credentials to the "email" and "pass" variables, then enter the following command:
`
ruby import_users.rb filename.csv
`
This will create each user and generate a log entry for any errors that occur.