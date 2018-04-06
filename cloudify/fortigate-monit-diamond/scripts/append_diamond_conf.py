from cloudify import ctx
from cloudify.state import ctx_parameters as inputs


target_instance = ctx.target.instance
target_node = ctx.target.node
src_instance = ctx.source.instance

config = src_instance.runtime_properties.get('fortigates_collector_config', {})

devices_conf = config.get('devices', {})
devices_conf[ctx.target.node.name] = device_config = {}
device_config['node_instance_id'] = target_instance.id
device_config['node_id'] = target_node.id
if 'host' in inputs:
    device_config['host'] = inputs.host
else:
    device_config['host'] = target_instance.host_ip
device_config['vdom'] = inputs.vdom

config['devices'] = devices_conf

src_instance.runtime_properties['fortigates_collector_config'] = config
