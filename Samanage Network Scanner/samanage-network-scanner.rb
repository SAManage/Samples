#!/usr/bin/env ruby

require 'nmap/program'
require 'nmap/xml'
require 'mac_vendor'
require 'samanage'


token = ARGV[0]
@samanage = Samanage::Api.new(token: token)
SCAN_XML = "nmap-data#{DateTime.now.strftime("%H-%M-%b-%d-%y")}.xml"
LOGFILE = "Assets Not Imported #{DateTime.now.strftime("%H-%M-%b-%d-%y")}.csv"
HEADERS = ['id','ipv4','os','mac','start_time','uptime','error']
####################################################
# This function is used to collect the correct type by mode
def find_type(type)
	type_return = type.inject({}) { |k, v| k[v] = type.count(v); k }
	type_return.select { |k,v| v == mode_return.values.max }.keys
end

def log_to_csv(other_asset: , filename: DEFAULT_FILENAME, headers: HEADERS)
    CSV.open(filename, 'a+', write_headers: true, force_quotes: true) do |csv| 
      csv << OUTPUT_HEADERS if csv.count.eql? 0
      csv << other_asset
    end
end


module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end


# https://github.com/sophsec/ruby-nmap
if OS.windows?
	Nmap::Program.scan do |nmap|
		nmap.syn_scan = true 
		nmap.service_scan = false 
		nmap.os_fingerprint = true 
		nmap.xml = SCAN_XML
		nmap.verbose = true 
		
		nmap.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080] 
		nmap.targets = ["192.168.0.*"]
		# nmap.targets = ["192.168.0.16"]
	end
else
	Nmap::Program.sudo_scan do |nmap|
		nmap.syn_scan = true 
		nmap.service_scan = false 
		nmap.os_fingerprint = true 
		nmap.xml = SCAN_XML
		nmap.verbose = true 

		nmap.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080] 
		nmap.targets = ["192.168.0.*"]
		# nmap.targets = ["192.168.0.16"]
	end
end
mac = MacVendor.new

puts "\n\n\n~~~~~~~~~~~~~~~~~~\nSyncing Samanage Records"
Nmap::XML.new(SCAN_XML) do |data|
	data.select{|h| h.mac}.each do |host|
		#This is a mandatory field
		if host.vendor.nil?
			manufacturer = "Unknown"
		else
			manufacturer = host.vendor
		end

		status = host.status.to_s
		
		if host.os.class == Array
			type = find_type(host.os.map(&:to_s))
		else
			type = host.os.first || "Unknown"
		end

		if status == 'up'
			 status = 'Operational'
		else
			status = 'Spare'
		end


		ipv4 = host.ipv4
		mac = host.mac
		uptime = host.uptime
		name = host.hostname || host.hostnames.first || host.vendor
		start_time = host.start_time
		os = host.os
		if name && type && mac
			other_asset = {
				other_asset: {
					name: name,
					ip: ipv4,
					manufacturer: manufacturer,
					asset_type: {name: type.to_s},
					status: {name: status},
					custom_fields_values:{
						custom_fields_value:[
							{name:'MacAddress',value: mac},
							{name:'Start Time',value: start_time},
							{name:'Uptime',value: uptime}
						]
					}
				}
			}
			samanage_id = @samanage.execute(path: "other_assets.json?MacAddress=#{host.mac}")[:data].first.to_h.dig('id')
			begin
				if samanage_id
					puts "Updating #{name} #{host.ipv4} [#{host.mac}] https://app#{@samanage.datacenter}.samanage.com/other_assets/#{samanage_id}"
					@samanage.update_other_asset(id: samanage_id, payload: other_asset)
				else
					puts "Creating #{name} #{host.ipv4} [#{host.mac}] https://app#{@samanage.datacenter}.samanage.com/other_assets/"
					@samanage.create_other_asset(payload: other_asset)
				end
			rescue Samanage::Error, Samanage::InvalidRequest => e
					error = {
						id: samanage_id,
						ipv4:ipv4,
						os:os,
						mac:mac,
						start_time:start_time,
						uptime:uptime,
						error: "#{e.status_code} - #{e.response}"
					}			
				log_to_csv(other_asset: error.values)
			end
		end
	end
end
