#!/usr/bin/env bash

#all in one
cfy install  blueprint.yaml -i inputs-citycloud.yaml


cfy upload blueprint blueprint.yaml
cfy deployment create -b fortios-mini-poc -i inputs-citycloud.yaml
cfy deployments update fortios-mini-poc -p blueprint.yaml -i inputs-citycloud.yaml
#Then install works too.
cfy executions start install -d fortios-mini-poc

#Tearing down
cfy executions start uninstall -d fortios-mini-poc
cfy executions start uninstall -d fortios-mini-poc --force -p ignore_failure=true
cfy deployments delete fortios-mini-poc
cfy deployments delete fortios-mini-poc force
cfy blueprint delete fortios-mini-poc

