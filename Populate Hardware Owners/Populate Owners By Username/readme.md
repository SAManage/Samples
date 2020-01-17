## Solarwinds Owner Update

This script allows you to update users based on a username formula.
For example if the username on the hardware record is 'john.doe' it will assign the record to 'john.doe@yourdomain.com'

##### Before you start

1. Install ruby
2. - Clone this repo and `bundle`
     or - Download the file `update-hardware-owners-by-username.rb` and type `gem install samanage parallel`
     Edit the script with your email domain here

```ruby
  #...
  api_token = ARGV[0]
  @samanage = Samanage::Api.new(token: api_token)
  # Edit Below
  @email_domain = '@example.com'
  #...
```

##### To Run

`ruby update-hardware-owners-by-username.rb API_TOKEN`
