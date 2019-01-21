require 'samanage'
require 'csv'
api_token = ARGV[0]
input = ARGV[1]
datacenter = ARGV[2]

@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
csv_rows = CSV.read(input, headers: true, encoding: 'ISO-8859-1')

DEFAULT_FILENAME = "Results-#{input.split('.').first}-#{DateTime.now.strftime("%b-%d-%Y-%l%M")}.csv"
OUTPUT_HEADERS = csv_rows.headers << 'Error'


def log_to_csv(row: , filename: DEFAULT_FILENAME)
	CSV.open(filename, 'a+'){|csv| 
		csv << OUTPUT_HEADERS if csv.count.eql? 0
		csv << row
	}
end


def import_other_asset(row: )
	other_asset = {
		other_asset: {
			name: row['Name'],
			description: row['Description'],
			asset_id: row['Asset ID'],
			status: {name: row['Status']},
			asset_type: {name: row['Asset Type']},
			ip_address: row['IP'],
			manufacturer: row['Manufacturer'],
			model: row['Model'],
			serial_number: row['Serial Number'],
			owner: {email: row['Owner']},
			user: {email: row['User']},
			site: {name: row['Site']},
			department: {name: row['Department']},
			custom_fields_values: {
				custom_fields_value: [
					{name: 'Cost', value: row['Cost']},
					{name: 'Purchased From', value: row['Purchased From']}
				]
			}
		}
	}
	@samanage.create_other_asset(payload: other_asset)
	rescue Samanage::Error, Samanage::InvalidRequest => e
	  error = "#{e.status_code} - #{e.response}"
	  row['Error'] = error
	  log_to_csv(row: row.values)
end


csv_rows.map{|row| import_other_asset(row: row.to_h)}
