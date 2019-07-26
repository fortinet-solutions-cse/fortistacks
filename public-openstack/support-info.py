#!/usr/bin/env python
#ref: https://docs.openstack.org/openstacksdk/latest/user/connection.html
import openstack
import pprint
import json
# Initialize and turn on debug logging
openstack.enable_logging(debug=False)

# Initialize cloud relying on sourcing the auth file.
conn = openstack.connect()

server=conn.compute.find_server("fgt60")
server_infos=conn.compute.get_server(server)
pprint.pprint(server_infos)
addresses=server_infos.addresses
pprint.pprint(addresses["left"])

for address in addresses:
    print type(addresses[address])
    pprint.pprint(addresses[address])
    for port in addresses[address]:
        port_mac=port['OS-EXT-IPS-MAC:mac_addr']
        print ("port mac: "+port_mac)
        for port in conn.network.ports(mac_address=port_mac):
            pprint.pprint(conn.network.get_port(port).to_dict())
### must separate floating ips
## find subent and networks
## block devices
## flavor
## security groups
## logs ?