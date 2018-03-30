# Fortigate / Fortios on Openstack

The official documentation for Fortigate fortios is available here: 
https://docs.fortinet.com/d/fortigate-fortios-vm-openstack-cookbook 


# Fortios Differences

Fortios is a Fortigate (same functionnality) made to be even more cloud native.
Differences are:
- No license file but a Fortimanager acting as metering
- A first port called mgmt and dhcp enabled
- Native cloud-init support from metadata server in addition to config_drive.


# Day0

Both products support cloud-init like feature and config_drive.
There is a cloudinit_cdrom folder to help create the iso file for local kvm of CPEs.

On Openstack user_data is the Fortinet cli style and license file can be passed as a file or in a multi-mime part file.


You can use 
```bash
$ write-mime-multipart -o fos-user-data.txt config FGT.lic
```
(part of cloud-utils package on Ubuntu)

# Port security

When used as a forwarding/NAT device Fortigate/Fortios need to get a port in promiscuous mode.
This is the port security disable parameter you can find in scripts and templates.

The allowed addrress pairs can be used to replace port-security disabled.

The examples in this folder are here to show you directly how to configure Fortigate on Cloud environment.

# Day2

Configuration is a strong part of firewalls and security. Fortinet provides APIs on all our products to configure them.
Ask an account on https://fndn.fortinet.com to know more and check our other github projects.
 