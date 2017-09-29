
# Cloudify 


Run ./deploy script and wait a bit. It install Cloudify 4.0 and create a LXC contained cloudify manager, configure it to use openstack.

Curious read the scripts :)

## Deploy
cd fortigate-mini-poc

## step by step:
cfy blueprint upload blueprint.yaml
cfy deployment create -b fortigate-mini-poc -i inputs.yaml
cfy executions start install -d fortigate-mini-poc

Teardown:
cfy executions start uninstall -d fortigate-mini-poc
cfy deployments delete fortigate-mini-poc
cfy deployments delete fortigate-mini-poc –force
cfy blueprint delete fortigate-mini-poc


Can do the same with fortios-mini-poc (for PAYG)
In that case modify blueprint IP adress of the fortimanager for metering if neeeded.
