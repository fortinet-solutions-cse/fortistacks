#!/bin/bash -x 

#Tearing down
[ -z "$1" ] && myblueprint="cloudify-ftnt-sdwan" || myblueprint=$1
openstack router unset dc-router --route destination=10.20.20.0/24,gateway=10.40.40.254
cfy executions start uninstall -d $myblueprint --force -p ignore_failure=true
sleep 6
cfy deployments delete $myblueprint
sleep 2
cfy blueprint delete $myblueprint

