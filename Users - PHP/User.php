<?php

		$userinfo = array(
       				'user' => array(
						'email' => 'EMAIL ADDRESS OF USER' ,
						'name' => 'NAME OF USER'
		   			)
		   	);				

$json = json_encode($userinfo);

echo "<PRE>";
print_r($json);

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_POST, TRUE);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
	curl_setopt($curl, CURLOPT_HEADER, FALSE);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_HTTPHEADER, array(
				'Accept: application/vnd.samanage.v1.1+json',
				'Content-Type: application/json'
				));
	curl_setopt($curl, CURLINFO_HEADER_OUT, TRUE);
	curl_setopt($curl, CURLOPT_VERBOSE, TRUE);
	curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_DIGEST);
	curl_setopt($curl, CURLOPT_USERPWD, 'API EMAIL ADDRESSS:PASSWORD');
	curl_setopt($curl, CURLOPT_URL, 'https://api.samanage.com/users.json');
	curl_setopt($curl, CURLOPT_POSTFIELDS, $json); 

// execute the request

$output = curl_exec($curl);

$info = curl_getinfo($curl);

if (empty($response)) {
	echo "<BR><BR> CURL INFO <BR><BR> <PRE>";
	print_r($info);
	die(curl_error($curl));
	curl_close($curl); // close cURL handler
} else {
	$info = curl_getinfo($curl);
	echo " CURL INFO <PRE>";
	print_r($info);
}

$output = json_decode($output, true);

//Print formatted JSON
echo "<BR><BR> JSON DECODED <BR><BR>  <PRE>";
print_r($output);

?>