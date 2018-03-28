#!/usr/bin/env bash

#all in one
cfy install  blueprint.yaml -i inputs-citycloud.yaml


cfy upload blueprint blueprint.yaml
cfy deployment create -b fortigate-mini-poc -i inputs-citycloud.yaml
cfy deployments update fortigate-mini-poc -p blueprint.yaml -i inputs-citycloud.yaml


cfy secret create fgt_license -f ../../fortigate/FGT.lic 
#Then install works too.
cfy executions start install -d fortigate-mini-poc

#Tearing down
cfy executions start uninstall -d fortigate-mini-poc
cfy executions start uninstall -d fortigate-mini-poc --force -p ignore_failure=true
cfy deployments delete fortigate-mini-poc
cfy deployments delete fortigate-mini-poc force
cfy blueprint delete fortigate-mini-poc

