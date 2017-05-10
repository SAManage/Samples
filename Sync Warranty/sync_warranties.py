import csv
import sys
import requests
import json
from datetime import datetime

# Initialize CSV
input_file = sys.argv[1]
warranties = []
csv_file = csv.DictReader(open(input_file))
for line in csv_file:
	warranties.append(line)

# API Controller
class Samanage:
	def __init__(self, argv):
		self.email =  sys.argv[2]
		self.password = sys.argv[3]
		# Check for EU data center, or default to US
		if len(sys.argv) >= 5:
			if str(sys.argv[4]).lower() == 'eu':
				self.dc = sys.argv[4]
			elif str(sys.argv[4]).lower() == 'us':
				self.dc = ''
			else:
				print('Invalid Datacenter:', sys.argv[4])
				quit()
		else:
			self.dc = ''
		self.base_url = 'https://api' + self.dc + '.samanage.com/'
		self.initialize()

	# Validate API credentials
	def initialize(self):
		path = 'api.json?per_page=100'
		api_call = requests.get(self.base_url + path, auth=(self.email, self.password))
		if api_call.status_code > 201:
			print("Invalid User/Password")
			print("Please enter 'python sync_warranties.py warranties.csv email@address password")
			quit()

	# Sync warranty based on serial number and CSV data
	def sync_warranty(self, serial_number, warranty):
		path = 'hardwares.json?serial_number[]=' + str(serial_number)
		api_call = requests.get(self.base_url + path, auth=(self.email, self.password))
		hardware = api_call.json()
		# Sync if exactly 1 asset found AND serial matches exactly
		if (len(hardware) == 1) and (hardware[0]['serial_number'] == serial_number):
			print("Updating ",hardware['name'], 'Start: ',warranty['Start Date'], ' End: ', warranty['End Date'],' --- ',hardware['url'])
			self.create_warranty(hardware[0]['id'], warranty)
		else:
			print('Serial Number: ', str(serial_number), 'Not Found or multiple matches: https://app.samanage.com/' + path)

	# Determine status based on start & end dates
	def set_status(self, warranty):
		if warranty['End Date'] < datetime.now():
			return 'Expired'
		elif warranty['End Date'] > datetime.now() and warranty['Start Date'] < datetime.now():
			return 'Active'
		elif warranty['Start Date'] > datetime.now():
			return 'Future'

	# Convert dates & send Warranty to Samanage
	def create_warranty(self, hardware_id, warranty):
		path = 'hardwares/' + str(hardware_id) + '/warranties.json'
		warranty['Start Date'] = datetime.strptime(warranty['Start Date'], '%m/%d/%Y')
		warranty['End Date'] = datetime.strptime(warranty['End Date'], '%m/%d/%Y')
		status = self.set_status(warranty)
		warranty_json = {
		'warranty':{
			'service':warranty['Service'],
			'provider':warranty['Provider'],
			'start_date':str(warranty['Start Date']),
			'end_date':str(warranty['End Date']),
			'status': status
			}
		}
		api_request = requests.Session()
		headers = {'Content-Type':'application/json','Accept':'application/vnd.samanage.v2.0'}
		api_request.headers.update(headers)
		api_call = api_request.post(self.base_url + path, auth=(self.email, self.password), json=warranty_json)

# Initialize API Connector
api_controller = Samanage(sys.argv)
# For each Warranty, sync add warranty info
for warranty in warranties:
	api_controller.sync_warranty(warranty['Serial Number'], warranty)
