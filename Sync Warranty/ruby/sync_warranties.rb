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

def log_to_csv(row: , filename: DEFAULT_FILENAME, headers: OUTPUT_HEADERS)
    CSV.open(filename, 'a+', write_headers: true, force_quotes: true) do |csv| 
      csv << OUTPUT_HEADERS if csv.count.eql? 0
      csv << incident
    end
end


def sync_warranty(warranty: )
  hardware_id = @samanage.find_hardware_by_serial(serial_number: row['Serial Number'])
  start_date = Date.parse(warranty['Start_date'])
  end_date = Date.parse(warranty['End Date'])
  status = (start_date..end_date).include?(Date.today) ? true : false
  if hardware_id
    warranty = {
      warranty:{
        service:warranty['Service'],
        provider:warranty['Provider'],
        start_date:warranty['Start Date'],
        end_date:warranty['End Date'],
        status: status,
      }
    }
    @samanage.execute(
      http_method: 'post',
      path: "hardwares/#{hardware_id}/warranties.json",
      payload: warranty
    )
  end
  rescue => e
    warranty['Error'] = "#{e.class}: #{e}"
    log_to_csv(message: warranty.values)  
end


csv_rows.map{|row| sync_warranty(warranty: row.to_h)}