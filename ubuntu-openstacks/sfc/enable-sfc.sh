#!/bin/bash -ex
## script to enable sfc on already deployed openstack pike


juju run --application neutron-api,nova-compute "export LC_ALL=C; sudo pip install -c https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?h=stable/pike networking-sfc==5.0.0"

#crudini allows to make changes in ini files from scripts :)
juju run --application neutron-api,nova-compute "sudo apt -y install crudini"

initialplugins=`juju ssh neutron-api/0  "sudo crudini --get /etc/neutron/neutron.conf DEFAULT service_plugins"`

# if not already set (look for sfc string then add the config)
[[ ${initialplugins} != *"Sfc"* ]] && juju ssh neutron-api/0  "sudo crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins $initialplugins,networking_sfc.services.flowclassifier.plugin.FlowClassifierPlugin,networking_sfc.services.sfc.plugin.SfcPlugin"

juju ssh neutron-api/0  "sudo crudini --set /etc/neutron/neutron.conf sfc drivers ovs"
juju ssh neutron-api/0  "sudo crudini --set /etc/neutron/neutron.conf flowclassifier drivers ovs"
juju ssh neutron-api/0  "sudo systemctl restart neutron-server"

## Now enable on ovs on nova-compute nodes:

juju run --application nova-compute  "sudo crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent extensions sfc"

juju run --application nova-compute "sudo systemctl restart neutron-openvswitch-agent"

# give a bit of time
sleep 5
juju-wait -v

juju ssh neutron-api/0 "sudo neutron-db-manage --subproject networking-sfc upgrade head"
