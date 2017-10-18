#!/bin/bash -e

juju run --application nova-compute "sudo apt -y install crudini"
juju run --application nova-compute  "sudo crudini --set /etc/nova/nova.conf libvirt hw_machine_type x86_64=pc-i440fx-xenial"
juju run --application nova-compute "sudo systemctl restart nova-compute"

