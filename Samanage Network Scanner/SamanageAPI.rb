#!/usr/bin/env ruby

#This was tested with the following:
# => 	ruby 2.0.0p451 (2014-02-24) [i386-mingw32] from rubyinstaller.org
# =>	xml-simple (1.1.3)	
# => 	rest_client (1.7.3)
#
#
# The gems can be installed via: gem install xml-simple
# 

require 'rest_client'
require 'xmlsimple'
class SamanageAPI
	@email = ""
	@password = ""
	def self.get(path)
		response = RestClient::Request.new(
			:method => "get",
			:url => "https://api.samanage.com/" + path.to_s,
			:user => @email,
			:password => @password,
			:headers => { :accept => 'application/vnd.samanage.v1+xml', :content_type => :xml }
		)
		response = response.execute {|response| $results = response}
		case response.code
		when 200..201
			return {:success => true, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		when 500
			puts "Invalid Request"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		else
			#puts "Failed with code: #{response.code}"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		end			
	end
	def self.post(path, xml_input)
		response = RestClient::Request.new(
			:method => "post",
			:url => "https://api.samanage.com/" + path.to_s,
			:user => @email,
			:password => @password,
			:payload => xml_input,
			:headers => { :accept => 'application/vnd.samanage.v1+xml', :content_type => 'text/xml' }
		)
		response = response.execute {|response| $results = response}
		#puts response
		case response.code
		when 200..201
			return {:success => true, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		when 500
			puts "Invalid XML"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		else
			#puts "Failed with code: #{response.code}"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		end		
	end
	def self.put(path, xml_input)
			response = RestClient::Request.new(
			:method => "put",
			:url => "https://api.samanage.com/" + path.to_s,
			:user => @email,
			:password => @password,
			:payload => xml_input,
			:headers => { :accept => 'application/vnd.samanage.v1+xml', :content_type => 'text/xml' }
		)
		response = response.execute {|response| $results = response}
		case response.code
		when 200..201
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		when 500
			puts "Invalid XML"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		else
			#puts "Failed with code: #{response.code}"
			return {:success => false, :code => response.code, :xml => response, :data => XmlSimple.xml_in(response.to_str)}
		end		
		
	end
end


