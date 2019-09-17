#!/bin/bash -e
# #######
# Copyright (c) 2016 Fortinet All rights reserved
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


# this script add floating ips directed to the management port of the VMs
# this comes as an add on to minipoc-deploy.sh which does not contain floating anymore
# for better usuability in private clouds.



#if nova access not set then get them from nova.rc
if [ -x $OS_AUTH_URL ]; then 
  echo "get the Openstack access from ~/nova.rc"
  . ~/nova.rc
fi
#if EXT_NET variable not set use default (allow to have it as param from the .rc file)
[ -x $EXT_NET ] && EXT_NET=ext_net

[ -x $VMS ] && VMS="fortigate trafleft trafright"
for VM in $VMS
do
  # return 1 or 2 IP if floating is on
  MGMT_IPS=`openstack server show $VM -f value -c addresses| awk -F'; ' '/mgmt=/{sub(/.*mgmt=/, ""); {print $1}}'`
  FLOAT_IP=`echo $MGMT_IPS |awk -F ', ' '{print $2}'`
  if [ -z $FLOAT_IP ]
  then
    MGMT_IP=`echo $MGMT_IPS |awk -F ', ' '{print $1}'`
    MGMT_PORT=` openstack port list --fixed-ip subnet=mgmt_subnet,ip-address=$MGMT_IP -f value -c id`
    FLOAT_IP=`openstack  floating ip create $EXT_NET --port $MGMT_PORT -f value -c floating_ip_address`
    #openstack server add floating ip $VM $FLOAT_IP
    echo "$VM is associated to $FLOAT_IP"
  else
    echo "$VM is already associated to $FLOAT_IP"
  fi
done
