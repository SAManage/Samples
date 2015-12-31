#############################################################################################################
#
#!/usr/bin/perl
#
# This script mass sends activation emails to Samanage users.
# Once they receive the email they'll be prompted to create a user name and password to log into samanage.
# This script does not create new users or modify existing users. 
#
#
#
#
# To run- install Perl and required libraries and run the following command:
# This script was written and tested with perl 5, version 18, subversion 1 (v5.18.1)
#
#
# 			perl"_Send_Activation.pl" "example@email.com" "password"
# 
#
#
#
#
# Command for perl with ptkdb debugger
# 			
#			perl -d:ptkdb "_Send_Activation.pl" "example@email.com" "password"
#
#

use warnings;
use strict;
use POSIX qw(ceil);
use Data::Dumper;                   # This should be in the standard Perl install
use MIME::Base64;                   # This should be in the standard Perl install
use REST::Client;                   # This may need to be installed from CPAN
use XML::Simple;                    # This may need to be installed from CPAN

#If a Library is missing you can install it by typing "cpan install XML::Simple" in your command line.

#############################################################################################################

#
#  Get SAManage user and password from command-line
# 
#  You can also enter your password here manually. You can then run the script by double clicking
# 		ex: my $username = 'example@email.com'
#
#
my $username = shift;
my $password = shift;



#############################################################################################################
#
#  Set up a REST client
#
#
my $rest_client = REST::Client->new();
$rest_client->getUseragent->ssl_opts(verify_hostname => 0);
$rest_client->getUseragent->show_progress(0);


#############################################################################################################

#
#  Set up headers for POST and PUT
#
#
my $get_headers = {Accept => 'application/vnd.samanage.v1.1+xml', Authorization => 'Basic ' . encode_base64($username . ':' . $password)};
my $post_headers = {'Content-Type' => 'text/xml', Authorization => 'Basic ' . encode_base64($username . ':' . $password)};


#Get user list and total page count
$rest_client->GET('https://api.samanage.com/users.xml', $get_headers);
my $resp = XMLin($rest_client->responseContent());
my $max = ceil($resp->{'total_entries'} / $resp->{'per_page'}); 
my $page = 1;


while ($page <= $max){

	$rest_client->GET('https://api.samanage.com/users.xml?page=' . $page . '&?per_page=100', $get_headers);
	die "[".$rest_client->responseCode."] ".$rest_client->responseContent if ($rest_client->responseCode != 200);
	$resp = XMLin($rest_client->responseContent());
 
 
	#Attempt to send an activation email to each user
	foreach my $name (keys %{$resp->{'user'}}) {	
		my $userid = $resp->{'user'}->{$name}->{'id'};
		$rest_client->PUT('https://api.samanage.com/users/' . $userid . '.xml?send_activation_email=1&add_callbacks=1', '', $post_headers);
		


		my $rcode = $rest_client->responseCode();  
		#rcode is the Rest Response code number
		my $rcontent = $rest_client->responseContent(); 
		#rcontent is the full page we response. This may have more detailed information about why request failed
			
		if (($rcode != 201) && ($rcode != 200)) {
		#User has already been activated and no activation was sent
		} 
		else {
			printf "Activation email sent to $name -- $resp->{'user'}->{$name}->{'email'}\n";
		}
	}
	#Indexes through user list page by page
	$page++;
}
	

#############################################################################################################
#
#
# You can track the status of these and other emails here
# https://app.samanage.com/setup/email_logs?report_id=-1
#
#

exit 0;