# Fortigate / Fortios on Openstack

This doc refers to fortigate or fortios folders in the project.

The official documentation for Fortigate fortios is available here: 
https://docs.fortinet.com/d/fortigate-fortios-vm-openstack-cookbook 


# Fortios

Fortios is a Fortigate (same functionnality) made to be even more cloud native.
Differences are:
- No license file but a Fortimanager acting as metering
- A first port called mgmt instead of port1

# Fortigate/Fortios image

Get the image tagged for KVM from [https://support.fortinet.com](https://support.fortinet.com) unzip and put the 
fortios.qcow2 file in this directory. Fortios for metering contact your Fortinet rep.

# Image upload
If using ```minipoc-deploy.sh``` you can skip this part.

You can upload fortios.qcow2 to Openstack Glance (images) or check the following example
````bash
openstack image create --disk-format qcow2 --container-format bare   "fortigate-621"  --file fortios.qcow2
````

# Cloud-init

In order to use [minipoc-deploy.sh](minipoc-deploy.sh) you must create a fgt-userdata.txt

Fortigate understand user_data is the Fortinet cli style and license file can be passed as a file or in a 
multi-mime part file.

Some openstack environment limit the size of the file that can be pass and new Fortinet licnese file are too big, 
use multi-mime in that case.

## no license
In that case simply copy [confg.txt](config.txt) like this:
````bash
$ cp config.txt fgt-userdata.txt 
````
## With license
Assume you license file is called FGT.lic 
Do 
```bash
$ write-mime-multipart -o fgt-userdata.txt config.txt FGT.lic
```

#Mini-poc as a script

With fortios.qcow2 and fgt-userdata.txt ready simply run:
```bash
$ ./minipoc-deploy.sh
```

This [script](minipoc-deploy.sh) is imdepotent, verbose by default and contain all the specific openstack command to deploy and connect a 
Fortigate. It is provided as an example to understand the integration point between Openstack and Fortigate.

Please read it.

# Port security

When used as a forwarding/NAT device Fortigate/Fortios need to get a port in promiscuous mode.
This is the port security disable parameter you can find in scripts and templates.

The allowed addrress pairs can be used to replace port-security disabled.

The examples in this folder are here to show you directly how to configure Fortigate on Cloud environment.

# Day1/2

Configuration is a critical part of firewalls and security. 

Fortinet provides APIs on all our products to configure them.
Ask an account on https://fndn.fortinet.com to know more and check our other github projects.
 