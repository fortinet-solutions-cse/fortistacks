#!/usr/bin/env bash

#all in one
cfy install  blueprint.yaml -i inputs-citycloud.yaml


cfy upload blueprint blueprint.yaml
cfy deployment create -b fortios-with-plugins -i inputs-citycloud.yaml


cfy executions start uninstall -d fortios-with-plugins
cfy deployments delete fortios-with-plugins
cfy deployments delete fortios-with-plugins force
cfy blueprint delete fortios-with-plugins

