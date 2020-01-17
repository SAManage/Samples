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


def assign_hardware_owner(row: )
	hardwares = @samanage.find_hardwares_by_serial(serial_number: row['Serial Number'])[:data]
	hardware_id = hardwares.select{|h| h['serial_number'] == row['Serial Number']}.first.to_h['id']
	if hardware_id
		hardware_owner_update = {
			hardware: {
				owner: {email: row['Owner']}
			}
		}
		@samanage.update_hardware(id: hardware_id, payload: hardware_owner_update)
	else
		row['Error'] = 'Hardware not found'
		log_to_csv(row: row.to_h.values)
	end
	rescue => e
		row['Error'] = e
		log_to_csv(row: row.to_h.values)
end


csv_rows.map{|row| assign_hardware_owner(row: row)}