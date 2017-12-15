# New user-data:

Example of User Data:

1). If using NOVA command, can use the following format.
nova boot --flavor "${flavor}" --image "${image}" --user-data=cloudinit --nic net-id=${netid} --security-group default test


This is the content of the cloudinit userdata file.
Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config sys global
    set hostname openstack
end

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="FGVM02DC10310004.txt"

-----BEGIN FGT VM LICENSE-----
QAAAADiM1vns1XCYqEF0t30wzWVUhdSj9huv+eUzPc+/UL7c1LtDv1sQde6vwi6A
UDxz8sL6YuoPV/4oHC28wiyriSJQAAAAItcbSUOpQBKNkKxev3grgnk6JQzdyq0A
rhc4ZQ8cGGEFxcqisz8vOd410duoRfsz4LbG5RjWXp7vX9LvZcQRmTMBEY70iXD5
OyUoz7yQE9M=
-----END FGT VM LICENSE-----

--===============0086047718136476635==--



2). If use HEAT template, can use the following format
fgt_config:
  type: OS::Heat::SoftwareConfig
  properties:
    group: ungrouped
    config: |
      config sys glo
      set hostname Openstack
      end
      config sys dns
      set primary 172.16.100.100
      set secondary 172.16.100.80
      end

 fgt_license:
  type: OS::Heat::SoftwareConfig
  properties:
    group: ungrouped
    config: |
       -----BEGIN FGT VM LICENSE-----
       QAAAANSykhlcKicp/SIwya0a4SWIEiIdEQRBu7OvnX5LBzBzCf324SJqHi5vVZLv
       rcP+S5+yXbzLPz8UqHXdDIClOuRQAAAAm4h8/oNxfatCrqMRKElK/ez4MaF4HXrf
       mSsAJV+0ecC3ZNqNrex+ROXWhOJAAPDqWb5yCFtSJ5HgHZFkntRQoXgifsP7WWAX
       81M8mYZlp18=
       -----END FGT VM LICENSE-----

 fgt_init:
  type: OS::Heat::MultipartMime
  properties:
    parts:
     - config: {get_resource: fgt_license}
     - config: {get_resource: fgt_config}


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
