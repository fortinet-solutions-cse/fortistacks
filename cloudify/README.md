
# Cloudify 

Source your openstack credentials.

On your own Fortistacks on Ubuntu

Run ./deploy script and wait a bit. It install Cloudify 4.0 and create a LXC contained cloudify manager, configure it to use openstack.

On public-openstack you must have the Cloudify manager image first.

Get the qcow2 image from here: http://repository.cloudifysource.org/cloudify/4.2.0/ga-release/cloudify-manager-4.2ga.qcow2 It is a 5G file.

Either upload manually:
```shell
openstack image create cfy-manager4.2 --file cloudify-manager-4.2ga.qcow2 --disk-format qcow2 --container-format bare
```
Or put in cloudify folder before running.
```shell
./manager-on-openstackvm
```

Using a browser go to the floatingip (or lxc ip)
of Cloudify.

## Quick Deploy
```shell
cd fortigate-mini-poc
```
Add your license:
```
cfy secret create fgt_license -f ../../fortigate/FGT.lic 
cfy install  blueprint.yaml -i inputs-citycloud.yaml
```

## step by step and tear down:
```
cfy blueprint upload blueprint.yaml
cfy deployment create -b fortigate-mini-poc -i inputs.yaml
cfy executions start install -d fortigate-mini-poc
```
Teardown:
```
cfy executions start uninstall -d fortigate-mini-poc
cfy deployments delete fortigate-mini-poc
cfy deployments delete fortigate-mini-poc –force
cfy blueprint delete fortigate-mini-poc
```

Can do the same with fortios-mini-poc (for PAYG)
In that case modify blueprint IP adress of the fortimanager for metering if neeeded.
