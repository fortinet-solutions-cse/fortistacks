#!/bin/bash -xe
# #######
# Copyright (c) 2019 Fortinet All rights reserved
# Author: Nicolas Thomas nthomas_at_fortinet.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    * See the License for the specific language governing permissions and
#    * limitations under the License.


# this create a jumphost on ovh

#if nova access not set then get them from nova.rc
if [ -x $OS_AUTH_URL ]; then
  echo "get the Openstack access from ~/nova.rc"
  . ~/nova.rc
fi

#if EXT_NET variable not set use default (allow to have it as param from the .rc file)
[ -x $EXT_NET ] && EXT_NET=Ext-Net
[ -x $OS_FLAVOR ] && OS_FLAVOR=s1-2
[ -x $UB_IMAGE ] && UB_IMAGE="Ubuntu 18.04"

[ -f jumphost_userdata.txt ] || (echo " you must have create a user-data file see README"; exit 2)

UB_USERDATA=jumphost_userdata.txt

#Push image if needed
openstack image show "$UB_IMAGE" > /dev/null 2>&1 ||  (echo " can not find $UB_IMAGE image"; exit 2)

#Create left network  for tenant VMs with a route to right network
openstack network show mgmt > /dev/null 2>&1 ||  (echo " No mgmt network defined run ./configure-openstack script"; exit 2)


if (openstack server show jumphost  > /dev/null 2>&1 );then
    echo "jumphost already installed"
else
    openstack server create  --image "$UB_IMAGE" jumphost --key-name default --security-group default --flavor $OS_FLAVOR --user-data $UB_USERDATA --network $EXT_NET --network mgmt --wait
fi

echo "Jumphost details :"
openstack server list --instance-name jumphost