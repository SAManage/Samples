# frozen_string_literal: true

require 'samanage'
require 'csv'
api_token = ARGV[0]
input = ARGV[1]
datacenter = ARGV[2]

@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
csv_rows = CSV.read(input, headers: true, encoding: 'ISO-8859-1')

DEFAULT_FILENAME = "Results-#{input.split('.').first}-#{DateTime.now.strftime('%b-%d-%Y-%l%M')}.csv"
OUTPUT_HEADERS = csv_rows.headers << 'error'

def log_to_csv(row:, filename: DEFAULT_FILENAME)
  CSV.open(filename, 'a+') do |csv|
    csv << OUTPUT_HEADERS if csv.count.eql? 0
    csv << row
  end
end

def assign_hardware_owner(row:)
  hardware = @samanage.hardwares(options: { serial_number: row['Serial Number'] })
                      .first.to_h

  hardware_id = hardware.dig('id')

  if hardware_id
    puts "Assigning #{hardware['name']} => #{row['Owner']}"
    payload = { hardware: { owner: { email: row['Owner'] } } }
    @samanage.update_hardware(id: hardware_id, payload: payload)
  else
    log_to_csv(row: row.merge(error: 'Hardware Not Found'))
  end
rescue Samanage::Error, Samanage::InvalidRequest => e
  row['Error'] = "#{e.status_code} - #{e.response}"
  log_to_csv(row: row.to_h.values)
end

csv_rows.map(&:to_h).map { |row| assign_hardware_owner(row: row) }
