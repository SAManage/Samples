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


def import_hardware(row: )
	hardware = {
		hardware: {
			name: row['Name'],
			bio: {
				manufacturer: row['Manufacturer'],
				model: row['Model'],
				ssn: row['Serial Number'],
			},
			category: {name: row['Category']},
			site: {name: row['Site']},
			department: {name: row['Department']},
			ip: row['ip'],
			status: row['Status'],
			asset_tag: row['tag'],
			technical_contact: {email: row['technical contact']},
			owner: {email: row['Owner']},
			custom_fields_values: {
				custom_fields_value: [
					{name: 'Insurance', value: row['Insurance']},
					{name: 'Refresh Date', value: row['Refresh Date']}
				]
			}
		}
	}
	@samanage.create_hardware(payload: hardware)
	rescue => e
		log_to_csv(row: row.to_h.values)
end


csv_rows.map{|row| import_hardware(row: row)}