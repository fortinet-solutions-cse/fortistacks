#!/usr/bin/env python
# ref: https://docs.openstack.org/openstacksdk/latest/user/connection.html
# use export OS_CACERT=/etc/ssl/certs/Fortinet_CA_SSL.pem if using SSL decription
# API infos/reference specs: https://docs.openstack.org/openstacksdk/latest/user/proxies/compute.html

import openstack
import pprint
import copy
import sys
## if option to redirect to file
#sys.stdout = open('file', 'w')

# Initialize and turn on debug logging
openstack.enable_logging(debug=False)
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--verbosity", help="increase output verbosity")
parser.add_argument('vms', metavar='N', type=str, nargs='+',
                    help='names of the VM to collect infos from')
args = parser.parse_args()
if args.verbosity:
    openstack.enable_logging(debug=True)

# Initialize cloud relying on sourcing the auth .rc (envirenment varialbles) file.
conn = openstack.connect()
result = dict()

for vm in args.vms:
    server = conn.compute.find_server(vm)
    server_infos = conn.compute.get_server(server)
    result[vm]= {'compute':''}
    result[vm]['compute'] = server_infos.to_dict()

    addresses = server_infos.addresses
    # there is the type Floating in the Addresses.. could find it to get floating info
    result[vm]['metadata'] = conn.compute.get_server_metadata(server).to_dict()

    result[vm]['console_output'] = conn.compute.get_server_console_output(server)

    result[vm]['ports']= {}
    for port  in  conn.compute.server_interfaces(server):
        port_id =  port.to_dict()['port_id']
        result[vm].keys().append(port_id)
        result[vm]['ports'][port_id] = conn.network.get_port(port_id).to_dict()

    result[vm]['volumes']= {}
    for volume in server_infos.attached_volumes:
        result[vm]['volumes'][volume['id']] = conn.compute.get_volume_attachment(volume['id'],server).to_dict()

    # USING THE tYPE IN FLOATING FIND THE ipS THEN THE DEtails
    result[vm]['floatings'] = {}
    for address in addresses:
        for port in addresses[address]:
            if port['OS-EXT-IPS:type'] == 'floating':
                result[vm]['floatings'][port['addr']] = conn.network.find_ip(port['addr']).to_dict()

pprint.pprint(result)



     # find subent and networks
    ## block devices
    ## flavor
    ## security groups
    ## logs (event log can not be found but console_log_output yes).
