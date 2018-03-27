# Public OpenStack thanks to citycloud

Go to https://citycontrolpanel.com/openstack#openstack_api_access line with user there a wheel on the right you can download rc file to get cli access



# Limitations 

- No horizon gui (for now) but a Gui
- Can't create your own flavors (not a big problem)

# Own Ubuntu or Docker image

# Upload images 

Fortigate go to https://support.fortinet.com and download the last fortigate VM image.
Those scripts start with 5.6.3 (previous version may work)

```shell
openstack image create fgt56 --file fortios.qcow2 --disk-format qcow2 --container-format bare
```

For Cloudify 

```shell
openstack image create cfy-manager4.2 --file Downloads/cloudify-manager-4.2ga.qcow2 --disk-format qcow2 --container-format bare
```
