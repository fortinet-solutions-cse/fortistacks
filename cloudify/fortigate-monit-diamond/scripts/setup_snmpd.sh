#!/bin/bash

set -e

sudo apt-get update
sudo apt-get -y install snmpd

# Some hacky string substitutions performed on the snmpd's config file..
SNMPD_CONFIG=/etc/snmp/snmpd.conf
sudo sed -i '/agentAddress  udp:127.0.0.1:161/d' $SNMPD_CONFIG
sudo sed -i -- 's/#agentAddress udp:161/agentAddress udp:161/g' $SNMPD_CONFIG
sudo sed -i -- 's/\-V\ssystemonly//g' $SNMPD_CONFIG

sudo service snmpd restart

