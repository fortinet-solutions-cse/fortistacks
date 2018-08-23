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

