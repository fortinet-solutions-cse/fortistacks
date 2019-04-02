
# Cloudify 

The goal here is to give you a working and configured Cloudify to be able to use the Fortinet Examples.
If you already have yours just go straight to the examples in the sub directories.


## Get Cloudfiy on Openstack.

Source your openstack credentials

Run 
```bash
cd cloudify/
./manager-on-openstackvm 
```
This script will:
 * find a Centos image
 * install the Cloduify CLI in your ubuntu environment (Docker or native)
 * if needed create a cloudify ssh key for access and push it to manager (for cloudify Agents)
 * Install and configure Cloudify manager for your environment.
 * Set the admin password to fortinet
 
Using a browser go to the floatingip of Cloudify manager

## Quick example
```shell
cd fortigate-mini-poc
```
Add your license:
```shell
cfy secret create fgt_license -f ../../fortigate/FGT.lic 
cfy install  blueprint.yaml -i inputs-citycloud.yaml
```

## More examples

There is more examples using Clodify in subdirectory in secure-sdwan directory. Check README associated.
