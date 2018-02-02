# Network Scanning Interface for Samanage

The following scripts are provided by Samanage as examples and training purposes only and not designed to work in every use case without some modification to the script itself. These scripts are not supported by Samanage as part of your Samanage Master Subscription Agreement, however if you would like this script customized to support your use case, please contact us at API.Scripts@samanage.com for a personal quote.

## Use Case 

Enhance the Samanage IT asset management solution to collect inventory of networked assets across your network, and manage these assets through the Samanage application.

## Using NMAP for network scanning

The following solution is using the popular open source NMAP tool to scan your network and detect any networked device, and collect their information. NMAP is a very popular and robust network scanning open source solution that is actively maintained by the community. NMAP runs on Windows or Unix.

## How does it work?

The code example below is a ruby-gem that: Invokes the NMAP tool to collect the network inventory Parses the output from the NMAP tool Upload the parsed information to Samanage using the Samanage API. Create a report of all assets collected that were not imported automatically along with the reason.

It is recommend to run the code below periodically to detect new devices on your network and load them into Samanage.

## Configuration

To use the tool, follow this steps

1) Download and install nmap [here](https://nmap.org/) 

2) Get the network scanning code [here](https://github.com/SAManage/Samples/blob/master/Samanage%20Network%20Scanner/samanage-network-scanner.rb)

3) Add a new custom field called "MacAddress" to your Other Asset object via the setup section in Samanage. The tool will populate this field with the MacAddress of the collected devices.

4) Install the samanage ruby gem `gem install samanage`

5) Create additional Asset Types in your Other Asset module. If the appropriate asset type does not exist when the tool runs, an error message will be displayed and that asset will not get into your inventory. Typical types that you will want to add are: “general purpose”, “Unknown”, “VoIP Phone”.

6) Edit the sample code to provide your subnet prefix - for example 192.168... that means that the entire subnet of 192.168 will be scanned. You can provide multiple subnet ranges by separating them via commas. (Lines #39)
```ruby
  nmap.targets = ["192.168.0.*"]
  # For multiple ranges:
  # nmap.targets = ["192.168.0.*","10.10.10.*"]
```

You can run the script by typing "ruby samanage-network-scanner.rb API_TOKEN DATACENTER"
