# Mediaserver

After extensive search for a proper and automatable media server I choose:
- Antmedia: https://antmedia.io/ 
It is opensource, available, easy to install on Linux as a service. Supports WebRTC; rtrmp etc..
- OBS: https://antmedia.io/how-to-use-obs-with-ant-media-server/

# Components
- fortigates 1 per branch office.
- Fortimanager to manage fortigates (Element manager)
- Cloudify orchestrator and fortimanager RESTAPI plugin
- Cloud environment (citycloud openstack in my case)
- Client simulated VMs.
- Router VM to introduce WAN latency, jitter, loss (default in iptables)

# Using netem
https://wiki.linuxfoundation.org/networking/netem to simulate a WAN with a linux VM.

## Config from claudio demo as examples:

```bash
config system interface
    edit "wan1"
        set vdom "root"
        set mode dhcp
        set allowaccess ping fgfm
        set type physical
        set role wan
        set snmp-index 1
    next
    edit "wan2"
        set vdom "root"
        set mode dhcp
        set allowaccess ping fgfm
        set type physical
        set role wan
        set snmp-index 2
    next
    edit "dmz"
        set vdom "root"
        set ip 10.210.8.61 255.255.254.0
        set allowaccess ping https ssh http
        set type physical
        set role dmz
        set snmp-index 3
    next
    edit "modem"
        set vdom "root"
        set mode pppoe
        set type physical
        set snmp-index 6
    next
    edit "ssl.root"
        set vdom "root"
        set type tunnel
        set alias "SSL VPN interface"
        set snmp-index 7
    next
    edit "internal"
        set vdom "root"
        set ip 192.168.1.99 255.255.255.0
        set allowaccess ping https ssh http fgfm capwap
        set type hard-switch
        set stp enable
        set device-identification enable
        set role lan
        set snmp-index 8
    next
    edit "Branch-Lan"
        set vdom "root"
        set ip 100.2.0.254 255.255.255.0
        set allowaccess ping
        set alias "LAN"
        set device-identification enable
        set role lan
        set snmp-index 14
        set interface "internal"
        set vlanid 303
    next
    edit "Branch-MPLS"
        set vdom "root"
        set ip 20.20.20.1 255.255.255.252
        set allowaccess ping
        set scan-botnet-connections block
        set alias "MPLS"
        set role wan
        set snmp-index 15
        set interface "wan1"
        set vlanid 301
    next
    edit "Branch-ISP"
        set vdom "root"
        set ip 20.20.20.5 255.255.255.252
        set allowaccess ping
        set scan-botnet-connections block
        set alias "ISP"
        set role wan
        set snmp-index 16
        set interface "wan2"
        set vlanid 304
    next
end

fg-vm-branch2 # config system virtual-wan-link 

fg-vm-branch2 (virtual-wan-link) # show
config system virtual-wan-link
    set status enable
    config members
        edit 2
            set interface "Branch-MPLS"
            set gateway 20.20.20.2
        next
        edit 3
            set interface "Branch-ISP"
            set gateway 20.20.20.6
        next
    end
    config health-check
        edit "HC"
            set server "4.4.4.1"
            set members 2 3
            config sla
                edit 1
                next
            end
        next
    end
    config service
        edit 1
            set name "business-critical-app"
            set mode priority
            set internet-service enable
            set health-check "HC"
            set priority-members 3 2
        next
        edit 2
            set name "non-business-critical-app"
            set mode priority
            set internet-service enable
            set health-check "HC"
            set priority-members 3
        next
        edit 3
            set name "Shared-Server"
            set mode priority
            set dst "APACHE-Server"
            set health-check "HC"
            set priority-members 2 3
        next
    end
end

```