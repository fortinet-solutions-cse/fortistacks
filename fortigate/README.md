
# Fortigate/Fortios specifics to virtualized environment and fortistacks setup:


To be able to use cloud-init config-drive is mandatory even if no license file is passed.

note: If not available on your cloud can you can start one vm, configure/license, create a snapshot and use the snapshot as the "golden" image.

MTU is 1500 by default no autoadapt. Most production clouds use 1500. Here because we run on a small/dev environment we need to adapt to the MTU size set in the openstack bundle. Look for instance-mtu in the ubuntu-openstack folder.

Provided port on overlay network must have anti-spoofing disabled. Port security is now an option in OpenStack so you must validate it works.
Of course it is set on Fortistacks.

neutron port-update 02f54ebf-57ce-45d2-b690-0526ee7e7429 --no-security-groups --port_security_enabled=False


For Fortios or closed environment:

Cloud-init can be configured per Openstack and point to fortimanager for licensing (Fortios+PAYG) or localy deployed (license files + fortigate)

First interface is mgmt (Fortios) be sure to start/connect with the management network as the first on the image (to be checked)

. /nova.rc

#Push image
openstack image create --disk-format qcow2 --container-format bare  --public  "FGT VM64"  --file fortios.qcow2
#http://docs.openstack.org/user-guide/cli-cheat-sheet.html
cat << EOF > fgt-user-data.txt
config system interface
 edit "port1"
  set mode dhcp
  set allowaccess ping https ssh http snmp fgfm
  set mtu 1456
  set defaultgw enable 
 next
 edit "port2"
  set mode dhcp
  set allowaccess ping
  set mtu 1456
  set defaultgw disable
 next
end
config system dns
 set primary 8.8.8.8
end
config sys global
 set hostname myfgtvm
end
EOF

#check the full example in fgt-user-data.txt in this folder.
#Tried (ref http://docs.openstack.org/cli-reference/nova.html)

nova boot --image "FGT VM64" FGT1 --key-name default --security-group default --flavor m1.small --user-data fgt-user-data.txt --config-drive=true --file license=FGVMUL0000075926.lic --nic net-name=mgmt


## trick if not using console/vnc you can redirect a port on your machine to the port off a VM or service in Fortistacks like this:
sudo iptables -t nat -A PREROUTING -p tcp --dport 4043 -j DNAT --to-destination 10.10.11.15:443
