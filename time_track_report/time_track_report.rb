# frozen_string_literal: true

require "samanage"
require "csv"

api_token, datacenter = ARGV
@samanage = Samanage::Api.new(token: api_token, datacenter: datacenter)
REPORT_FILENAME = "Report - Time Tracks - #{DateTime.now.strftime('%b-%m-%Y  %H%M')}.csv"

def log_to_csv(row:, filename: REPORT_FILENAME, headers: [])
  write_headers = !File.exist?(filename)
  CSV.open(filename, "a+", write_headers: write_headers, force_quotes: true) do |csv|
    csv << headers if csv.count.eql? 0
    csv << row
  end
end

def convert_time(minutes)
  h = minutes / 60
  m = (minutes % 60).to_s.rjust(2, "0")
  "#{h}:#{m}"
end

@samanage.incidents(options: { verbose: true, 'updated[]': 30 }).each do |incident|
  next if incident["time_tracks"].to_a.empty?

  @samanage.time_tracks(incident_id: incident["id"]).each do |time_track|
    # if some_custom_validation
    #   next
    # end
    time_entered = convert_time(time_track["minutes"].to_i)
    row = {
      "Time Track Entered By" => time_track.dig("creator", "email"),
      "Time Entered (h:m)" => time_entered,
      "Time Entered At" => time_track["created_at"],
      "Incident URL" => "https://app#{datacenter}.samanage.com/incidents/#{incident['id']}",
      "Incident Number" => incident["number"],
      "Incident State" => incident.dig("state"),
      "Incident Created At" => incident["created_at"],
      "Incident Updated At" => incident["updated_at"],
      "Incident Category" => incident.dig("category", "name"),
      "Incident Subcategory" => incident.dig("subcategory", "name"),
      "Incident Site" => incident.dig("site", "name"),
      "Incident Department" => incident.dig("department", "name"),
      "Incident Assignee Email" => incident.dig("assignee", "email"),
      "Incident Assignee Name" => incident.dig("assignee", "name"),
      "Incident Requester Email" => incident.dig("requester", "email"),
      "Incident Requester Name" => incident.dig("requester", "name")
      # Add / remove columns here from time track or parent incident data.
    }
    log_to_csv(row: row.values, headers: row.keys)
  end
end
