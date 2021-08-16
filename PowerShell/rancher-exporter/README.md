# Rancher configuration exporter

This is meant to serve as an easy-to-use script that can export Rancher clusters into JSON that can be committed to source control management or a CMDB. It includes specification files per component that filter out unneeded fields to sanitize the output a little bit.

### Usage

 Run the script from a directory of your choosing. The script will generate an "autoexport" directory that it will place the output files into.

 Flags include:

 - RancherTokenUsername: The Rancher API token username obtained from the RKE UI
 - RancherTokenPassword: The Rancher API token password obtained from the RKE UI
 - RancherURL: The URL of the Rancher instance to use