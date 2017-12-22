require 'samanage'

@token = ARGV[0]
@api_controller = Samanage::Api.new(token: @token)
users = @api_controller.users
users.reject!{|u| u['last_login']}.map{|u| @api_controller.send_activation_email(email: u['email'])}