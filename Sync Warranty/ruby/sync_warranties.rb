require 'samanage'
require 'csv'
require 'date'
# require 'ap'

api_token = ARGV[0]
input = ARGV[1]
datacenter = ARGV[2]
@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
csv_rows = CSV.read(input, headers: true, encoding: 'ISO-8859-1')
OUTPUT_HEADERS = csv_rows.headers << 'Error'
DEFAULT_FILENAME = "Errors-#{input.split('.').first}-#{DateTime.now.strftime("%b-%d-%Y-%l%M")}.csv"

def log_to_csv(message: , filename: DEFAULT_FILENAME, headers: OUTPUT_HEADERS)
    CSV.open(filename, 'a+', write_headers: true, force_quotes: true) do |csv| 
      csv << OUTPUT_HEADERS if csv.count.eql? 0
      csv << message
    end
end


def set_status(start_date, end_date)
  if end_date < Date.today
    'Expired'
  elsif (start_date..end_date).include?(Date.today)
    'Active'
  else
    'Future'
  end
end


def sync_warranty(warranty: )
  hardware = @samanage.find_hardwares_by_serial(serial_number: warranty['Serial Number'])[:data]
  puts "#{hardware}"
  hardware_id = hardware.select{|h| h.dig('serial_number') == warranty['Serial Number']}.first.to_h.dig('id')
  puts "hardware_id: #{hardware_id}"
  start_date = Date.strptime(warranty['Start Date'], "%m/%d/%Y")
  end_date = Date.strptime(warranty['End Date'], '%m/%d/%Y')
  status = set_status(start_date, end_date)
  if hardware_id
    warranty = {
      warranty:{
        service:warranty['Service'],
        provider:warranty['Provider'],
        start_date:start_date,
        end_date:end_date,
        status: status,
      }
    }
    puts warranty.inspect
    @samanage.execute(http_method: 'post',path: "hardwares/#{hardware_id}/warranties.json",payload: warranty)
  else
    puts "Hardware serial: #{warranty['Serial Number']} not found"
  end
rescue Samanage::Error, Samanage::InvalidRequest => e
    warranty['Error'] = "#{e.class}: #{e}"
    log_to_csv(message: warranty.values)  
end


csv_rows.map{|row| sync_warranty(warranty: row.to_h)}