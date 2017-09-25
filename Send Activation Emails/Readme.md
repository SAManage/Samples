This script sends activation emails to your Samanage user list.
Once they receive the email they'll be prompted to create a user name and password to log into samanage.
This script does not create new users or modify existing users.


To run this script first install **Ruby 2.3+** and the gem **samanage**

To invite all your users to Samanage run the command:

`ruby send_activations.rb API_TOKEN`