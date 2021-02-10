# frozen_string_literal: true

require "samanage"
require "csv"
# require 'ap'

api_token = ARGV[0]
@samanage = Samanage::Api.new(token: api_token)
@email_domain = "@example.com"


@has_account = {}

def is_user?(email)
  return if !email

  @has_account[email] ||= !@samanage.users(options: { 'email[]': email, verbose: true })
    .select { |u| u["email"].to_s.downcase == email.to_s.downcase } # Ensure it is not a fuzzy match  -- u['email'] will always exist
    .empty?
end


hardwares = @samanage.hardwares
hardwares.each do |hardware|
  hardware_has_username = !hardware["username"].to_s.empty?
  email = hardware_has_username ? "#{hardware['username']}#{@email_domain}" : false
  if is_user?(email)
    url = hardware["href"].gsub(".json", "").gsub("api", "solarwinds")
    puts "#{url} Assigning [#{hardware['name']}] to #{email.inspect}"
    @samanage.update_hardware(
      id: hardware["id"],
      payload: { hardware: { owner: { email: email } } }
    )
  else
    puts "No Service Desk user associated with #{hardware['name']} - #{hardware['username'].inspect}"
  end
end
