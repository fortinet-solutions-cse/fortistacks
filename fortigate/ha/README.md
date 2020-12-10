# HA examples.

You must create/update you env files.


# Network and testers

The file [[ heat-nets-ubuntu.yaml ]] is a template to deply 3 networks (in addition to mgmt) and 2 VMs connected to 2 different ones to have a test environment.


openstack stack create --template heat-nets-ubuntu.yaml networks -e citycloud-nets.env 


# FGCP example

openstack stack create --template heat-fgt-fgcp.yaml fgcp -e citycloud-fgcp.env 

