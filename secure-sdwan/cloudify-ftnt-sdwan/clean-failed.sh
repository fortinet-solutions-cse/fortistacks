#!/bin/bash -x 

#Tearing down

cfy executions start uninstall -d cloudify-ftnt-sdwan --force -p ignore_failure=true
cfy deployments delete cloudify-ftnt-sdwan
cfy deployments delete cloudify-ftnt-sdwan force
cfy blueprint delete cloudify-ftnt-sdwan

