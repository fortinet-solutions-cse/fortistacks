#!/bin/bash -x 

#Tearing down
[ -z "$1" ] && myblueprint="cloudify-ftnt-sdwan" || myblueprint=$1

cfy executions start uninstall -d $myblueprint --force -p ignore_failure=true
cfy deployments delete $myblueprint
sleep 12
cfy blueprint delete $myblueprint

