require 'samanage'
require 'csv'

api_token = ARGV[0]
input = ARGV[1]
datacenter = ARGV[2]
@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
csv_users = CSV.read(input, headers: true, encoding: 'ISO-8859-1')
OUTPUT_HEADERS = csv_users.headers << 'Errors'
DEFAULT_FILENAME = "Errors-#{input.split('.').first}-#{DateTime.now.strftime("%b-%d-%Y-%l%M")}.csv"

def log_to_csv(user: , filename: DEFAULT_FILENAME, headers: OUTPUT_HEADERS)
  CSV.open(filename, 'a+', write_headers: true, force_quotes: true) do |csv|
    csv << headers if csv.count.eql? 0
    csv << user
  end
end


def sync_user(user: )
    user_json = {
      user: {
        email: user['email'],
        name: user['name'],
        title: user['title'],
        phone: user['phone'],
        department: { name: user['department']},
        custom_fields_values: {
          custom_fields_value: [
            {name: "Nickname", value: user['nickname']}
          ]
        }
      }
    }

  user_id = @samanage.find_user_id_by_email(email: user['email'])

  if user_id
    puts "Updating #{user['email']} found"
    @samanage.update_user(payload: user_json, id: user_id)
  else
    puts "Creating #{user['email']}"
    @samanage.create_user(payload: user_json)
  end

  rescue => e
    user['error'] = "#{e.status_code}: #{e.response}"
    log_to_csv(user: user.values)
end

csv_users.map{|user| sync_user(user: user.to_h)}