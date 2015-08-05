#SamanageAPI
##Overview

SamanageAPI is a simple Ruby class that provides easy connectivity to the Samanage API. 

##How to use

Using this script is very simple. SamanageAPI is a ruby Class that allows you to send Rest API calls to Get/Post/Put items into Samanage by passing a path, email, user and optional data as arguments.

##Initialization
To begin using this function, simply require SamanageAPI.rb in your ruby script.

```ruby
require_relative 'SamanageAPI.rb'
```



##Getting data from Samanage
Example: To 'get' users

```ruby
users = SamanageAPI.get("users.xml", "email@company.com","password")
```

When succesful **users** will contain hash with the following keys:

key | type | description
--- | ---- | -----------
users["success"] | Boolean | Can be used to verify a successful call 
users["code"] | Fixnum | [Status code](http://www.restapitutorial.com/httpstatuscodes.html) returned for advanced error reporting
users["response"] | String | Response returned from API call as a string
users["data"] | Hash | Response returned from the API as parasble hash


##Creating user in Samanage
```ruby
email = "api.user@company.com"
pass = "password"
xml = "<user><name>John Doe</name><email>john.doe@company.com</email></user>"
call = SamanageAPI.post("users.xml", email, pass, xml)
```
When correct information is returned call["success"] should be set to true and  call["code"] will return 201 - Created
