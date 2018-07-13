#!/bin/bash -xe

cfy blueprint upload  blueprint.yaml
cfy deployment create -b fortigate-monitored -i inputs-citycloud.yaml --skip-plugins-validation
cfy executions start install -d fortigate-monitored

