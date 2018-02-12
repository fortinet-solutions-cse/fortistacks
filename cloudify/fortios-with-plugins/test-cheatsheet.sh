#!/usr/bin/env bash

#all in one
cfy install  blueprint.yaml -i inputs-citycloud.yaml


cfy upload blueprint blueprint.yaml
cfy deployment create -b fortios-with-plugins -i inputs-citycloud.yaml
cfy deployments update fortios-with-plugins -p blueprint.yaml -i inputs-citycloud.yaml
#Then install works too.
cfy executions start install -d fortios-with-plugins

#Tearing down
cfy executions start uninstall -d fortios-with-plugins
cfy executions start uninstall -d fortios-with-plugins --force -p ignore_failure=true
cfy deployments delete fortios-with-plugins
cfy deployments delete fortios-with-plugins force
cfy blueprint delete fortios-with-plugins

