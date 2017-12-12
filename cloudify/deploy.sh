#!/bin/bash -xe
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


#Follow http://docs.getcloudify.org/
export LC_ALL=C

sudo apt -y install python-pip python-virtualenv wget git
#sudo pip install --upgrade pip
wget -c http://repository.cloudifysource.org/cloudify/4.2.0/ga-release/cloudify-cli-4.2ga.deb

sudo dpkg -i cloudify*.deb

lxc launch images:centos/7/amd64 cfy-mngr && sleep 12
# Create a centos container and access to put cfy mngr there
#Follow http://docs.getcloudify.org/3.4.1/cli/bootstrap/

LXCm="lxc exec cfy-mngr -- "
$LXCm ping -c 4 github.com
$LXCm yum -y update
$LXCm yum -y install openssh-server anacron gcc python-devel sudo wget which java python-backports-ssl_match_hostname python-setuptools python-backports make systemd-sysv
$LXCm rpm -U --force http://mirror.centos.org/centos/7/os/x86_64/Packages/openssl-1.0.2k-8.el7.x86_64.rpm
$LXCm mkdir -p /root/.ssh
# check this https://groups.google.com/forum/#!topic/cloudify-users/U1xMdkZ0HqM
lxc file push ~/.ssh/id_rsa.pub cfy-mngr/root/.ssh/authorized_keys
lxc file push ~/.ssh/id_rsa cfy-mngr/root/
$LXCm chown root:root /root/.ssh/authorized_keys
echo -e "fortinet\nfortinet" | $LXCm passwd
JAVACMD=`$LXCm which java`
echo "export JAVACMD=$JAVACMD" | $LXCm tee -a /etc/environment
$LXCm sudo reboot
sleep 5
$LXCm ping -c 4 github.com
export LXCmIP=`lxc exec cfy-mngr -- ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
ssh-keyscan $LXCmIP >> $HOME/.ssh/known_hosts

envsubst < cfy-lxc-mngr.template >  lxc-manager-blueprint-inputs.yaml

cfy init -r
#Colors in the logs
sed -i 's/colors: false/colors: true/g' $HOME/.cloudify/config.yaml
cfy bootstrap --install-plugins /opt/cfy/cloudify-manager-blueprints/simple-manager-blueprint.yaml -i lxc-manager-blueprint-inputs.yaml
#--task-retry-interval 15 --task-retries 3  --keep-up-on-failure
    #|| echo "error catched but keep going anyway"
#Ref : http://docs.getcloudify.org/plugins/openstack/
. ~/nova.rc
envsubst < openstack_config.template | $LXCm tee /etc/cloudify/openstack_config.json
cfy init -r
cfy profiles use $LXCmIP -u admin -p fortinet -t default_tenant 
cfy profiles set -t default_tenant -u admin -p fortinet   
#install openstack plugin
wget -c https://s3-eu-west-1.amazonaws.com/cloudify-release-eu/cloudify/wagons/cloudify-openstack-plugin/2.3.0/cloudify_openstack_plugin-2.3.0-py27-none-linux_x86_64-centos-Core.wgn
cfy plugins upload cloudify_openstack_plugin-2.3.0-py27-none-linux_x86_64-centos-Core.wgn 


cat <<EOF
To use cloudify run:
Then cfy cli is fonctionnal see http://docs.getcloudify.org/4.2/cli/overview/
log with admin/fortinet to http://$LXCmIP
For completion run: eval "\$(_CFY_COMPLETE=source cfy)" 
EOF
