#!/bin/bash -ex
cfy blueprint upload -b lcm blueprint.yaml
cfy deployment create --skip-plugins-validation lcm -b lcm -i inputs-citycloud.yaml
cfy -v executions start -d lcm install