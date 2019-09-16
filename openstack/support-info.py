#!/usr/bin/env python
# ref: https://docs.openstack.org/openstacksdk/latest/user/connection.html
# use export OS_CACERT=/etc/ssl/certs/Fortinet_CA_SSL.pem if using SSL decription
# API infos/reference specs: https://docs.openstack.org/openstacksdk/latest/user/proxies/compute.html
from __future__ import print_function
import openstack
import pprint

import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

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
    eprint("collect compute info of " + vm)
    server = conn.compute.find_server(vm)
    server_infos = conn.compute.get_server(server).to_dict()

    result[vm]= {'compute':''}
    result[vm]['compute'] = server_infos

    addresses = server_infos['addresses']
    # there is the type Floating in the Addresses.. could find it to get floating info
    eprint("collect metadata info of "+vm)
    result[vm]['metadata'] = conn.compute.get_server_metadata(server).to_dict()
    eprint("collect console output info of "+vm)
    result[vm]['console_output'] = conn.compute.get_server_console_output(server)
    eprint("collect flavor info of "+vm)
    result[vm]['flavor'] = conn.compute.get_flavor(server_infos['flavor']['id']).to_dict()
    eprint("collect image info of "+vm)
    result[vm]['image'] = conn.compute.get_image(server_infos['image']['id']).to_dict()


    result[vm]['ports']= {}
    result[vm]['networks']= {}
    ## we collect networks /subnet of the ports
    eprint("collect ports, networks and security group info of " + vm)
    for port  in  conn.compute.server_interfaces(server):
        port_id =  port.to_dict()['port_id']
        result[vm].keys().append(port_id)
        result[vm]['ports'][port_id] = conn.network.get_port(port_id).to_dict()
        net_id = port.to_dict()['net_id']
        result[vm]['networks'][net_id] = conn.network.get_network(net_id).to_dict()
        ## check if a net_id/subnets aleady exist
        ## can append if 2 ports are on 2 subnet of same net without check will overide info
        try:
            alreadyset = result[vm]['networks'][net_id]['subnets']
        except KeyError:
            result[vm]['networks'][net_id]['subnets'] ={}
        for fix_ip in port.to_dict()['fixed_ips']:
            result[vm]['networks'][net_id]['subnets'][fix_ip['subnet_id']] = conn.network.get_subnet(fix_ip['subnet_id']).to_dict()
        result[vm]['ports'][port_id]['security_groups'] = {}

        for sec_group in result[vm]['ports'][port_id]['security_group_ids']:
            result[vm]['ports'][port_id]['security_groups'][sec_group] = conn.network.get_security_group(sec_group).to_dict()

    result[vm]['volumes']= {}
    eprint("collect volume info of " + vm)
    for volume in server_infos['attached_volumes']:
        result[vm]['volumes'][volume['id']] = conn.compute.get_volume_attachment(volume['id'],server).to_dict()

    # USING THE tYPE IN FLOATING FIND THE ipS THEN THE DEtails
    eprint("collect floating info of " + vm)
    result[vm]['floatings'] = {}
    for address in addresses:
        for port in addresses[address]:
            if port['OS-EXT-IPS:type'] == 'floating':
                result[vm]['floatings'][port['addr']] = conn.network.find_ip(port['addr']).to_dict()

pprint.pprint(result)

    ## logs (event log can not be found but console_log_output yes).
