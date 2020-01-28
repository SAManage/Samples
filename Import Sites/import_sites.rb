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


def import_site(row:)
  site = {
    site: {
      name: row["name"],
      description: row["description"]
    }
  }
  @samanage.create_site(payload: site)
  rescue => e
    log_to_csv(row: row.to_h.values)
end


csv_rows.map { |row| import_site(row: row) }
