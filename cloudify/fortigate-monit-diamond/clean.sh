#!/bin/bash -x 

cfy executions start uninstall -d fortios-with-plugins -p ignore_failure=true || cfy executions start uninstall -d fortios-with-plugins --force -p ignore_failure=true

cfy deployments delete fortios-with-plugins || cfy deployments delete fortios-with-plugins force
cfy blueprint delete fortios-with-plugins

