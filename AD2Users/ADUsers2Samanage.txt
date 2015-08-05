#[CmdletBinding()]
#Param(
#  [Parameter(Mandatory=$True)]
#   [string]$SAM = $( Read-Host "Input SAM Account Name please" )
#   )
Import-Module -Name ActiveDirectory
$PSDefaultParameterValues = @{"*-AD*:Server"='gvdc1.d06.us'}
$allUsersXML = $null
# $user = (get-ADUser -identity $SA)
$login = "APIUSER@COMPANY.COM"
$password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
$credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $login, $password
Invoke-WebRequest -Uri "https://app.samanage.com/api.xml" -Credential $credential -Headers @{'Accept'='application/vnd.samanage.v1+xml'} -SessionVariable loggedin
"The properties of the websession.  Credentials are stored in there" 
"and headers after the first request for reuse in subsequent requests"
$loggedin >c:\1\updateSamanage.log
$samanageUsers = Invoke-RestMethod -Uri "https://toltsolutions.samanage.com/users.xml" -Method Get -WebSession $loggedin 
$totalUsers = $samanageUsers.users.total_entries
$perPage = $samanageUsers.users.per_page
$pages = $totalUsers/$perPage
$pages = [Math]::round( $pages, 0, [system.midpointrounding]::AwayFromZero)
[xml]$allUsersXML = $samanageUsers.users.user
Echo "Begin********************************PAGE********************1"
$samanageUsers.users.user.name
Echo "END********************************PAGE********************1"
"Total Pages - $pages"
for ($i=2; $i -le $pages; $i++){
	$samanageUsers = Invoke-RestMethod -Uri "https://toltsolutions.samanage.com/users.xml?page=$i" -Method Get -WebSession $loggedin
	Echo "Begin ********************************PAGE********************$i"
	$samanageUsers.users.user.name
	Echo "END ********************************PAGE********************$i"
	$allUsersXML += $samanageUsers.users.user
}

$allUsersXML | ForEach-Object {
    $_.name >>c:\1\updateSamanage.log
    $name = $_.name
    $id = $_.id
    $email = $_.email
    $exists = $null
    $manager = $null
    Try { $exists = Get-ADUser -Filter {(userPrincipalName -like $email)} -Properties telephoneNumber,mobile,manager,title,userPrincipalName }
    Catch { }
    $exists >>c:\1\updateSamanage.log
    $phone = $exists.telephoneNumber
    $mobile = $exists.mobile
    $managerDN = $exists.manager
    $title = $exists.title
    Try { $manager = Get-ADUser -Filter {(distinguishedName -like $managerDN)} }
    Catch { }
    $managerUPN = $manager.userPrincipalName
    $updateXML = "<user>"
    $updateXML += "<phone>$phone</phone>"
    $updateXML += "<mobile_phone>$mobile</mobile_phone>"
    $updateXML += "<title>$title</title>"
    $updateXML += "<reports_to><email>$managerUPN</email></reports_to>"
    $updateXML += "</user>"
    "XML to update the user $id $name" >>c:\1\updateSamanage.log
    $updateXML >>c:\1\updateSamanage.log
    $url = "https://api.samanage.com/users/"
    $url += $id
    $url += ".xml"
    $url >>c:\1\updateSamanage.log
    Invoke-RestMethod -Uri $url -Method Put -Body $updateXML -WebSession $loggedin -ContentType "text/xml" >>c:\1\updateSamanage.log
}


