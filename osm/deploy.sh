#!/bin/bash -x
#
#    fortinet-configure-openstack
#    Copyright (C) 2016 Fortinet  Ltd.
#
#    Authors: Nicolas Thomss  <nthomasfortinet.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#if nova access not set then get them from nova.rc
if [ -x $OS_AUTH_URL ]; then 
    echo "Source an Openstack credentials like . ~/nova.rc before running this"
    exit 2
fi

#install osm client

if (osm --help >/dev/null)
then
    echo "osm client already installed"
else
    curl http://osm-download.etsi.org/repository/osm/debian/ReleaseTHREE/OSM%20ETSI%20Release%20Key.gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] http://osm-download.etsi.org/repository/osm/debian/ReleaseTHREE stable osmclient"
    sudo apt-get update
    sudo apt-get install -y python-osmclient
fi

# used a modified version of the osm installer (no nat rules)
./install_osm.sh --lxdimages

#TODO add OSM IPs in nova.rc to make it easier
export OSM_HOSTNAME=`lxc list | awk '($2=="SO-ub"){print $6}'`
export OSM_RO_HOSTNAME=`lxc list | awk '($2=="RO"){print $6}'`

# Connect OSM to openstack

# TODO check if already done
# Ref: https://osm.etsi.org/wikipub/index.php/Openstack_configuration_(Release_THREE)
osm vim-create --name openstack --user $OS_USERNAME --password $OS_PASSWORD --auth_url $OS_AUTH_URL  \
    --tenant $OS_TENANT_NAME --account_type openstack  \
    --config='{use_floating_ip: True, use_existing_flavors: True, security_groups: default, keypair: default}'

echo "OSM configured to use the local openstack"
echo "creating install snapshots"
lxc snapshot RO install
lxc snapshot VCA install
lxc snapshot SO-ub install

echo "Using _chrome or chromium_ connect to https://$OSM_HOSTNAME:8443 admin/admin"
echo "source osm.rc to configure for your osm cli"
