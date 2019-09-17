# Fortigate / Fortios on Openstack

This doc refers to fortigate or fortios folders in the project.

The official documentation for Fortigate fortios is available here: 
https://docs.fortinet.com/d/fortigate-fortios-vm-openstack-cookbook 

# Fortigate/Fortios image

Get the image tagged for KVM from [https://support.fortinet.com](https://support.fortinet.com) unzip and put the 
fortios.qcow2 file in this directory. Fortios for metering contact your Fortinet rep.

# Image upload
If using ```minipoc-deploy.sh``` you can skip this part.

You can upload fortios.qcow2 to Openstack Glance (images) or check the following example
````bash
openstack image create --disk-format qcow2 --container-format bare   "fortigate"  --file fortios.qcow2
````

# Fortios

Fortios is a Fortigate (same functionnality) using metering for license (cloud native).
Differences are:
- No license file but a Fortimanager acting as metering
- A first port called mgmt instead of port1
- Contact Fortinet rep for details
- fortigate or fortios unziped image file is fortios.qcow2

# Cloud-init

In order to use [minipoc-deploy.sh](minipoc-deploy.sh) you MUST create a fgt-userdata.txt

Fortigate user_data is in the Fortinet cli style and license file can be passed in a multi-mime part file.

Sending the license as a file is supported by Fortigate meanwhile some openstack environment limit the size of the file 
that can be pass and Fortinet licenses file can be large.  
Use multi-mime in that case.

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
## Fortios
In that case simply copy [fos-user-data.txt](fos-user-data.txt ) like this:
````bash
$ cp fos-user-data.txt  fgt-userdata.txt 
````


#Mini-poc as a script

With fortios.qcow2 and fgt-userdata.txt ready simply run:
```bash
$ ./minipoc-deploy.sh
```

This [script](minipoc-deploy.sh) is imdepotent, verbose by default and contain all the specific openstack command to deploy and connect a 
Fortigate. It is provided as an example to understand the integration point between Openstack and Fortigate.

Please read it for details and to find the openstack commands related to fortigate.

If you don't have an image of fortigate already on Openstack, the script will take fortios.qcow2 in the running folder 
and upload.

Options:
* You can set ``` export FGT_IMAGE_NAME="myname" ``` to change the image name. It is recommended to add this to your 
openstack .rc file

## Access your deployment
* To access your environment use a jump host or network access to your management network.
* Use floating ips in that case [script](minipoc-add-floatings.sh) will add the floating ips to your VMs. 
(same behavior as before)

# Port security

When used as a forwarding/NAT device Fortigate/Fortios need to get a port in promiscuous mode.
This is the port security disable parameter you can find in scripts and templates.

The allowed addrress pairs can be used to replace port-security disabled.

The examples in this folder are here to show you directly how to configure Fortigate on Cloud environment.

# Day1/2

Configuration is a critical part of firewalls and security. 

Fortinet provides APIs on all our products to configure them.
Ask an account on https://fndn.fortinet.com to know more and check our other github projects.
 