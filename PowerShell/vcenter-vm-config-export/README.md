# vCenter VM config export script

I wrote this to quickly export the configured vCPU, memory, and storage for all VMs under specified folders in a vCenter instance. It exports into CSV format for reporting use, or use with a CMDB.

### Usage

 Flags include:
 
 - vCenterURL: The URL of the vCenter instance to use
 - SessionID: Your vCenter API session key
 - FolderNames: An array of folder names to search through (ex: "Discovered virtual machines","Lab","QA")
 - ExportFileName: The name (with or without the full path) of the CSV file to write