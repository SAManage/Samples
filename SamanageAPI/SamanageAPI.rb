#!/usr/bin/env ruby

#This was tested with the following:
# => 	ruby 2.0.0p451 (2014-02-24) [i386-mingw32]
# =>	xml-simple (1.1.3)	
# => 	rest_client (1.7.3)

require 'rest_client'
require 'xmlsimple'

class SamanageAPI
def self.get(path, email, pass)
response = RestClient::Request.new(:method => "get", :url => "https://api.samanage.com/" + path, :user => email, :password => pass, :headers => { :accept => 'application/vnd.samanage.v1.1+xml', :content_type => "xml" })
	begin
	response = response.execute {|response| $results = response}
	ret = {"success" => true, "code" => response.code, "xml" => response, "data" => XmlSimple.xml_in(response.to_str)}
	rescue
		ret = {"success" => false, "code" => response.code, "xml" => response, "data" => ''}
		return ret
	ensure
		return ret	
	end
end
def self.post(path, email, pass, xml_input)
response = RestClient::Request.new(:method => "post", :url => "https://api.samanage.com/" + path, :user => email, :password => pass, :payload => xml_input, :headers => { :accept => 'application/vnd.samanage.v1.1+xml', :content_type => 'text/xml' })
	begin
	response = response.execute {|response| $results = response}
	ret = {"success" => true, "code" => response.code, "xml" => response, "data" => XmlSimple.xml_in(response.to_str)}
	rescue 
		ret = {"success" => false, "code" => response.code, "xml" => response, "data" => ''}
		return ret
	ensure
		return ret
	end
end		
def self.put(path, email, pass, xml_input)
response = RestClient::Request.new( :method => "put", :url => "https://api.samanage.com/" + path, :user => email, :password => pass, :payload => xml_input, :headers => { :accept => 'application/vnd.samanage.v1.1+xml', :content_type => 'text/xml' })
	begin 
		response = response.execute {|response| $results = response}
		ret = {"success" => true, "code" => response.code, "xml" => response, "data" => XmlSimple.xml_in(response.to_str)}
	rescue 
		ret = {"success" => false, "code" => response.code, "xml" => response, "data" => ''}
		return ret
	ensure
		return ret
	end
end
end