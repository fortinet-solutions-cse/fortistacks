#!/bin/bash -ex
cfy blueprint upload -b scale blueprint.yaml
cfy deployment create --skip-plugins-validation scale -b scale -i inputs-citycloud.yaml 
cfy -v executions start -d scale install
