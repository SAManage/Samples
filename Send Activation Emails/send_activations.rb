# frozen_string_literal: true

require "samanage"

@token = ARGV[0]
@datacenter = ARGV[1]
@samanage = Samanage::Api.new(token: @token, datacenter: @datacenter)
@samanage.users.each do |user|
  user_needs_to_be_activated = !user["last_login"] && !user["disabled"]
  if user_needs_to_be_activated
    begin
      puts "Sending Activation to #{user['email']}"
      @samanage.send_activation_email(email: user["email"])
    rescue Samanage::Error, Samanage::InvalidRequest => e
      puts "[#{e}] #{e.status_code} - #{e.response}"
    end
  end
end
