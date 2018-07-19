#!/usr/bin/env bash

#Brutal way but easy and using 1 session (faster)
./bleach-floatingips.sh
cat << EOF | openstack
router remove subnet provider-router mgmt_subnet
router delete provider-router
network delete mgmt
keypair delete default
keypair delete cloudify
EOF
