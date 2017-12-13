# Test done using citycloud

Go to https://citycontrolpanel.com/openstack#openstack_api_access line with user there a wheel on the right you can download rc file to get cli access

#Limitation : no gui

#creating image
openstack image create cfy-manager4.2 --file Downloads/cloudify-manager-4.2ga.qcow2 --disk-format qcow2 --container-format bare
openstack image create fgt56 --file fortios.qcow2 --disk-format qcow2 --container-format bare

