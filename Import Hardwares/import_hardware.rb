# frozen_string_literal: true

require "samanage"
require "csv"
api_token = ARGV[0]
input = ARGV[1]
datacenter = ARGV[2]

@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
csv_rows = CSV.read(input, headers: true, encoding: "ISO-8859-1")

DEFAULT_FILENAME = "Results-#{input.split('.').first}-#{DateTime.now.strftime("%b-%d-%Y-%l%M")}.csv"
OUTPUT_HEADERS = csv_rows.headers << "Error"


def log_to_csv(row:, filename: DEFAULT_FILENAME)
  CSV.open(filename, "a+") { |csv|
    csv << OUTPUT_HEADERS if csv.count.eql? 0
    csv << row
  }
end


def import_hardware(row:)
  hardware = {
    hardware: {
      name: row["Name"],
      bio: {
        manufacturer: row["Manufacturer"],
        model: row["Model"],
        ssn: row["Serial Number"],
      },
      category: { name: row["Category"] },
      ip_address: row["ip"],
      asset_tag: row["tag"],
      custom_fields_values: {
        custom_fields_value: [
          { name: "Insurance", value: row["Insurance"] },
          { name: "Refresh Date", value: row["Refresh Date"] }
        ]
      }
    }
  }
  hardware[:hardware][:owner] = { email: row["Owner"] } if row["Owner"]
  hardware[:hardware][:site] =  { name: row["Site"] } if row["Site"]
  hardware[:hardware][:department] =  { name: row["Department"] } if row["Department"]
  hardware[:hardware][:technical_contact] =  { email: row["technical contact"] } if row["technical contact"]
  puts "Creating: #{row['Serial Number']}"
  @samanage.create_hardware(payload: hardware)
  rescue Samanage::Error, Samanage::InvalidRequest => e
    error = "#{e.status_code} - #{e.error}"
    p error
    row["Error"] = error
    log_to_csv(row: row.values)
end


csv_rows.map { |row| import_hardware(row: row.to_h) }
