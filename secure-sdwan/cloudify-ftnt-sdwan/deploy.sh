#!/bin/bash -ex
cfy blueprint upload -b acme acme-enterprise.yaml
cfy deployment create --skip-plugins-validation acme -b acme -i inputs-citycloud.yaml
cfy -v executions start -d acme install
# openstack router set dc-router --route destination=10.20.20.0/24,gateway=10.40.40.254