# Fortigate / Fortios on Openstack

The official documentation for Fortigate fortios is available here: 
https://docs.fortinet.com/d/fortigate-fortios-vm-openstack-cookbook 


# Create key
 ssh-keygen -t ecdsa -b 521 -N "" -C "key for guestcse" -f guestcse
 openstack keypair create  --public-key guestcse.pub  guestcse

# change envrionment file

 openstack stack create --template heat-ha-poc.yaml -e citycloud-env-ha.yaml ha-poc
### Following
 openstack stack event list ha-poc --follow

##