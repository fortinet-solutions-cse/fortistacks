
# Cloudify 


# mini-poc blueprint:
. $HOME/nova.rc
openstack image list                                                                   
openstack flavor list 


modify fortigate-mini-poc/inputs.yaml with the value from previous cmds:

fos_imageid: '7cb018a3-87f8-4137-b631-1a085e473efc'
fos_flavorid: '81fa4ad6-c010-425e-a107-c1666ac02f0c’
ub_imageid: ''
ub_flavorid: '81fa4ad6-c010-425e-a107-c1666ac02f0c’
mgmt_network_name: "mgmt"


## Deploy
cd fortigate-mini-poc
#does not work for now#cfy install  blueprint.yaml -i inputs.yaml -vv

## step by step:
cfy blueprint upload blueprint.yaml
cfy deployment create -b fortigate-mini-poc -i inputs.yaml
cfy executions start install -d fortigate-mini-poc

Teardown:
cfy executions start uninstall -d fortigate-mini-poc
cfy deployments delete fortigate-mini-poc
cfy deployments delete fortigate-mini-poc –force
cfy blueprint delete fortigate-mini-poc
