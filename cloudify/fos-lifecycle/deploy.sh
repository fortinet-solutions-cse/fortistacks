#!/bin/bash -ex
cfy blueprint upload -b lcm blueprint.yaml
cfy deployment create --skip-plugins-validation lcm -b lcm -i inputs-citycloud.yaml
cfy -v executions start -d lcm install

## To scale
#cfy executions start -d lcm scale --dry-run -p  scalable_entity_name=fos_fips -p delta=2