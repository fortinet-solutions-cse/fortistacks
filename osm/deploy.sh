#!/bin/bash -x

# used a modified version of osn installer (no nat rules)
./install_osm.sh --lxdimages

#need to add OSM IPs in nova.rc to make it easier
# add this at the end
#osm vim-create --name openstack --user admin --password fortinet --auth_url http://10.10.10.29:5000/v2.0 --tenant admin --account_type openstack

