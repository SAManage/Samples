require 'samanage'

api_token = ARGV[0]
input_file = ARGV[1]
csv_users = CSV.read(input_file, headers: true, encoding: 'ISO-8859-1')
OUTPUT_HEADERS = users.headers << 'Errors'
DEFAULT_FILENAME = "Errors-#{input_file.split('.').first}-#{DateTime.now.strftime("%b-%d-%Y-%l%M")}.csv"

def log_to_csv(user: , filename: DEFAULT_FILENAME)
		unless File.file?(filename)
				puts "Creating Error File: #{filename}"
				CSV.open(filename, 'a+'){|csv| csv << OUTPUT_HEADERS}
		end
		CSV.open(filename, 'a+'){|csv| csv << user}
end


def create_user(user: )
	puts "user: #{user.inspect}"
	user = {
		user: {
			name: user['name'],
			email: user['email'],
		}
	}
	@samanage.create_user(payload: user)
	rescue => e
		log_to_csv(row: row.to_h.values)
end


csv_users.map{|user| user(user: user.to_h)}