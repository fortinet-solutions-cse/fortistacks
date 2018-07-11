# Describe how to start on OpenStack.

Ref: https://docs.fortinet.com/d/fortimanager-5.6-vm-install


Get FMG_VM64_KVM-v5-build1631-FORTINET.out.kvm.zip from https://support.fortinet.com
unzip it.

```openstack image create --disk-format qcow2 --container-format bare  "FMG 5.6.2"  --file fmg.qcow2

openstack volume create --size 8 fmg-log1

export OS_FLAVOR="2C-4GB"
openstack server create --image "FMG 5.6.2" fmg56 --key-name default  --security-group default  \
           --flavor $OS_FLAVOR --nic net-id=mgmt,v4-fixed-ip=192.168.1.99
openstack server add volume fmg56 fmg-log1 --device /dev/vdb
```

You should have minimum changes if configuring mgmtB as 192.168.1.0/24 which is the default network Fortimanager is on.

You then need to update your interface to the openstack one (no dhcp)
```shell
openstack server list
+--------------------------------------+-------+--------+---------------------------------+-----------+--------+
| ID                                   | Name  | Status | Networks                        | Image     | Flavor |
+--------------------------------------+-------+--------+---------------------------------+-----------+--------+
| 42c2fd39-b27a-4111-b6fd-5e7c81626c52 | fmg56 | ACTIVE | mgmt=192.168.16.12, 77.81.7.183 | FMG 5.6.2 | 2C-4GB |
+--------------------------------------+-------+--------+---------------------------------+-----------+--------+
```

Adapt to your IP and gateway:



Log to the console (vnc on openstack), user admin  no passwd.
```bash
config system interface
edit port1
 set ip 192.168.1.99 255.255.255.0
end 
config system route
edit 1
        set device "port1"
        set gateway 192.168.1.1
#must match your network mtu#        set mtu 1400
end
execute lvm start
```
You must run the followin cli on FMG to be able to use the API
```bash
config system admin user
edit admin
set rpc-permit read-write
end
```