# POSH-DT

Powershell Module for interacting with Dynatrace API

This module is alpha/experimental and unfinished! No warranty provided.

[toc]

## Function list:

### Save-DTConfig
This function will save your connection settings including URL and API key as a secure string within a json file stored in your profile's 'Documents' folder.

 - PSCredential (optional)
 - dturl
	 - This is your full tenant URL up to FQDN
 - apikeyname
	 - This should be an identifier to uniquely identify this api key within the tenant. This will allow you to pull several API keys within a script.

### Load-DTConfig
Using this function will load a windows credential object containing tenant URL as the username and api key as the password.

- dturl
	- Tenant URL or Tenant subdomain. As the full URL is already in the json file, you just need the subdomain to identify the config file
- apikeyname
	- Unique identifier for the api key

### Write-DTLog

Write Logs to Dynatrace API

- message
	- Log message to be written
-  level
	- Log level: "Failure","Error","Alert","Critical","Severe","Warning","Notice","Information","Debug","Verbose"
-  dturl
	- subdomain or URL of tenant
-  apikeyname
	- Unique api key name

### Write-DTMetric

Future function to write dynatrace metrics
