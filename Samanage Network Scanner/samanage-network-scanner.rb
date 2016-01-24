#!/usr/bin/env ruby

require 'nmap/program'
require 'nmap/xml'
require 'mac_vendor'
require_relative 'SamanageAPI.rb'
####################################################
# This script requires 'nmap' to be installed
# 
# You can install the required gems with the following commands:
#  'gem install ruby-nmap'
#  'gem install mac_vendor'
#  'gem install xml-simple'
#  'gem install rest_client'





####################################################
# This function is used to collect the correct type.
def mode(mode)
	mode_return = mode.inject({}) { |k, v| k[v] = mode.count(v); k }
	mode_return.select { |k,v| v == mode_return.values.max }.keys
end



Nmap::Program.scan do |nmap|

	####################################################
	# SYN scan is the default and most popular scan option for good reasons. 
	# It can be performed quickly, scanning thousands of ports per second on a fast network not hampered by restrictive firewalls.
	#  It is also relatively unobtrusive and stealthy since it never completes TCP connections.
	# Service_Scan allows you to scan services on computers
	# OS Fingerprint is required to detect the type of asset.
	# Verbose mode will return more detailed data than normal, for example a timestamp for each port scanned.

	nmap.syn_scan = true 
	nmap.service_scan = false 
	nmap.os_fingerprint = true 
	nmap.xml = 'scan-db'
	nmap.verbose = true 

	####################################################
	# These are the common ports the script will check, if you need additional then add them to the list
	# This is your IP range to scan.

	nmap.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080] 
	nmap.targets = ["192.168.1.*", "192.168.3.*"]
	#nmap.targets = '192.168.1.*' 
end

mac = MacVendor.new
####################################################
# This sets up a CSV file.
# In the final version we can make it configurable between CSV and API
# The downside of the API is that you can not insert new 'types' of assets
# so if the type returned does not match an existing type in your account
# then the request will fail.
fname = "Assets Not Imported #{Time.now.strftime "%Y-%m-%d_%H-%M"}.csv"
error_log = File.new(fname, "w+")
error_log.write("Name,IP,Manufacturer,Asset Type,Asset Status,Mac,Error\n")
error_log.close

i = 0
# system('clear')
Nmap::XML.new('scan-db') do |data|
	data.each_host do |host|
		i += 1
		skip = false
		#puts host.hostnames
		####################################################
		#Skip the assets that are not returning data and the local machine
		#If the OS is not returned then we can not obtain enough information to create an asset

		if host.status.to_s.include? ("down" || "no-response")			
			puts "Machine #{host.ipv4} Not Found"
			next
		end
		if host.hostnames[0].to_s.include? "localhost-response"
			next
		end
		if host.mac.nil?
			puts "Machine #{host.ipv4} Mac Address Not Found"
			next
		end
		####################################################
		#Set Manufcaturer based on vendor
		#This is a mandatory field
		if host.vendor.nil?
			manufacturer = "Unknown"
		else
			manufacturer = host.vendor
		end

		status = host.status.to_s

		####################################################
		#The we may return multiple OS values so this block scans them all and guesses the type
		#based on the most common OS found
		type = Array.new
		host.os.each_class do |osclass|
			type.push(osclass.type.to_s)
		end
		type = mode(type)

		####################################################
		#This block prevents the Type from being empty
		case type
			when nil
				type = "Unknown"
			when ""
				type = "Unknown"
		end
		if type.any? == false
			type[0] = "Unknown"
		end

		####################################################
		#This block converts the status to operational
		###Internal: I have only ever gotten 'up' 'down' or 'no response'
		###Not sure if anything else can be returned, if so it could be a problem
		if status == 'up'
			 status = 'Operational'
		else
			status = 'Spare'
		end


		#This block checks to see if

		list = SamanageAPI.get("other_assets.xml?MacAddress=#{host.mac}")
		total = list[:data]["total_entries"][0]
		if total.to_i > 0
			puts "#{host.hostnames[0]}: Asset already exists"
			error_log = File.new(fname, "a+")
			error_log.write("#{host.hostnames[0]},#{host.ipv4},\"#{manufacturer}\",\"#{type[0]}\",#{status},#{host.mac},Matches: #{list[:data]["other_asset"][0]["href"][0]}\n")
			error_log.close
			next
		end

		####################################################
		# You can choose to skip any hosts just by checking a field, and conditionally setting skip = true
		# For example if the ip string value is 192.168.1.1:
		#
		#if host.ipv4.to_s == "192.168.1.1"
		#	skip = true
		#end

		if skip			
			next
		end
		####################################################
		#This block


		if host.hostnames[0].to_s.size > 0
			xml = "<other_asset>
			<name>#{host.hostnames[0]}</name>
			<ip>#{host.ipv4}</ip>
			<manufacturer>#{manufacturer}</manufacturer>
			<asset_type><name>#{type[0]}</name></asset_type>
			<status><name>#{status}</name></status>
			<custom_fields_values>
			<custom_fields_value>
				<name>MacAddress</name>
				<value>#{host.mac}</value>
			</custom_fields_value>
			</custom_fields_values>\n</other_asset>"
			#puts xml
			result = SamanageAPI.post('other_assets.xml', xml)
			if result[:success] == false
				error = result[:data]["error"][0]
				error.gsub(/\n/," ")
				error.gsub(/\r/," ")
				puts "#{host.hostnames[0]} Failed: #{error}"
				error_log = File.new(fname, "a+")
				error_log.write("#{host.hostnames[0]},#{host.ipv4},\"#{manufacturer}\",\"#{type[0]}\",#{status},#{host.mac},#{error}\n")
				error_log.close
			else
				puts "Imported: #{host.hostnames[0]}"
			end
		end
	end
end
