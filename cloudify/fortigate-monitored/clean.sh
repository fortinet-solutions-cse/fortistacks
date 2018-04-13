#!/bin/bash -x 

cfy executions start uninstall -d fortigate-monitored -p ignore_failure=true || cfy executions start uninstall -d fortigate-monitored --force -p ignore_failure=true

cfy deployments delete fortigate-monitored || cfy deployments delete fortigate-monitored force
cfy blueprint delete fortigate-monitored

