require 'samanage'
require 'awesome_print'

@token = ARGV[0]
@api_controller = Samanage::Api.new(token: @token)





def send_activation(user)
	return if user['last_login']
	puts "Sending activation email for: #{user['name']} - #{user['email']}"
	path = "users/#{user['id']}.json?send_activation_email=1&add_callbacks=1"
	@api_controller.execute(http_method: 'put', path: path);0
	rescue Samanage::InvalidRequest, Samanage::Error => e
		puts "Error: #{e} - #{e.class}"
		puts "#{e.status_code} - #{e.response}"
	rescue JSON::ParserError => e
		# puts "#{e} - #{e.class}"
end




init = @api_controller.execute(path: 'users.json?per_page=100')
max_pages = init[:headers]['X-Total-Pages'].to_i
page = 1
while page <= max_pages
	path = "users.json?page=#{page}"
	users = @api_controller.execute(path: path)[:data]
	users.map{|u| send_activation(u)}
	page += 1
end