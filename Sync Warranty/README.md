# Samanage Warranty Sync Script


This simple script allows you to sync warranty information into Samanage using Python.

## Requirements
- [Python 3.6+](http://python.org/download)
- Pip (included natively in python installer)
- Python [Requests](http://docs.python-requests.org/en/master/user/install/#install) module
- CSV of Warranty information (Use our attached template!)
- Native Samanage Email & Password login (single sign on credentials are not supported)
	- This can be verified here: https://app.samanage.com/login?native=true or https://appeu.samanage.com/login?native=true
	- A new password can be requested here https://app.samanage.com/password/new or https://appeu.samanage.com/password/new


## Instructions
- Download and install Python 3.6 and pip
- Install the python module **Requests**:
	- ``` pip install requests ```
- Compile your warranty information into the above **warranties.csv** template
- From the script directory use the command:
	- US datacenter: ```python sync_warranties.py warranties.csv email@domain.com password```
	- EU datacenter: ```python sync_warranties.py warranties.csv email@domain.com password eu```


### Notes
1. Dates are parsed explicitly using the format 01/31/2000. If you wish to use a different date format this can be modified here:
```python
warranty['Start Date'] = datetime.strptime(warranty['Start Date'], '%m/%d/%Y')
warranty['End Date'] = datetime.strptime(warranty['End Date'], '%m/%d/%Y')
```
For more information on date formatting visit the [Python docs](https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior)

2. All warranties included in the CSV will be uploaded. Please exclude any expired warranties if you do not wish to import them.