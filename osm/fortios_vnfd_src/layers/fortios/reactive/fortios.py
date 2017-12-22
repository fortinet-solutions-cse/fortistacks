
from charmhelpers.core.hookenv import (
    config,
    status_set,
    action_get,
    action_set,
    action_fail,
    log,
)

from charms.reactive import (
    when,
    when_not,
    helpers,
    set_state,
    remove_state,
)


from charms import fortios
import logging
import json
import ast
#to convert single to double quote for json..
formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
logger = logging.getLogger('fortiosapi')
hdlr = logging.FileHandler('/var/tmp/fortiosapilib.log')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr) 
logger.setLevel(logging.DEBUG)

cfg = config()

@when('config.changed')
def config_changed():
    status_set('maintenance', 'trying to connect and validate config')
    remove_state('fortios.configured')
    try:
        log("trying to get system status")
        if fortios.connectionisok(vdom="root"):
            log('API call successfull response')
            set_state('fortios.configured')
            status_set('active','alive')
        else:
            remove_state('fortios.configured')
            status_set('blocked', fortios+' can not be reached')
            raise Exception(fortios+' unreachable')
    except Exception as e:
        log(repr(e))
        status_set('blocked', 'validation failed: %s' % e)
        remove_state('fortios.configured')
        not_ready_add()
        log("can not rest log to fortios")

@when_not('fortios.configured')
def not_ready_add():
    if helpers.any_states(*actions):
        action_fail('FORTIOS is not configured')
    status_set('blocked', 'fortios is not configured')


@when('actions.apiset','fortios.configured')
def apiset():
    """
    Configure an ethernet interface
    """
    name = action_get('name')
    path = action_get('path')
    params = action_get('parameters')
    
    status_set('maintenance', 'running cmd on fortios')
    log("in apiset call")
    # multi line is accepted with \n to separate then converted because juju does not allow advanced types like list or json :(
    try:
        mydata={}
        for line in params.split("\\n"):
            log("line is:"+line)
            key=line.split(":")[0].strip()
            value=line.split(":")[1].strip()
            mydata[key]=value
        res, resp = fortios.set(name,path,data=mydata)
        if res:
            action_set({'output': resp})
        else:
            action_fail('API call on fortios failed reason:' + repr(resp))
        remove_state('actions.apiset')
        status_set('active', 'alive')
    except Exception as e:
         action_fail('API call on fortios failed reason:'+repr(e))
         remove_state('actions.apiset')
         status_set('active','alive')




@when('fortios.configured','actions.sshcmd')
def sshcmd():
    '''
    Create and Activate the network corporation
    '''
    commands = action_get('commands').split("\\n")
    # multi line is accepted with \n to separate then converted because juju does not allow advanced types like list or json :(
    cmdsMultiLines="""
    {}
    """.format("\n".join(commands))

    status_set('maintenance', 'running cmd on fortios')
    try:
        log("trying to run cmd: %s on fortios" % cmdsMultiLines )
        stdout,stderr = fortios.sshcmd(cmdsMultiLines)
    except Exception as e:
         action_fail('cmd on fortios failed reason:'+repr(e))
    else:
        log('sshcmd resp %s' % stdout)
        action_set({'output': stdout})
    remove_state('actions.sshcmd')
    status_set('active','alive')


@when('update-status')
def update_status():
    try:
        """
        Using the fortiosapi lib to connect to rest api
        """
        if fortios.connectionisok(vdom="root"):
            status_set('active', 'alive')
            set_state('fortios.configured')
        else:
            remove_state('fortios.configured')
            status_set('blocked', fortios+' can not be reached')
            raise Exception(fortios+' unreachable')
    except Exception as e:
        log(repr(e))
        status_set('blocked', 'validation failed: %s' % e)

@when('fortios.configured','actions.conf-port')
def conf_port():
    """
    Configure an ethernet interface
    """
    port = action_get('port')
    ip = action_get('ip')
    mtu = action_get('mtu')
    netmask = action_get('netmask')
    if mtu:
        params = {
            "name": port,
            "mode": "static",
            "ip": ip+" "+netmask,
            "allowaccess":"ping",
            "mtu-override":"enable",
            "mtu":mtu
        }  
    else:
        params = {
            "name": port,
            "mode": "static",
            "ip": ip+" "+netmask,
            "allowaccess":"ping",
            "vdom":"root"
        }
    status_set('maintenance', 'running cmd on fortios')
    try:
        is_set, resp = fortios.set("system","interface",data=params)
    except Exception as e:
         action_fail('API call on fortios failed reason:'+repr(e))
    else:
        if is_set is True:
            log('API call successfull response %s' % resp)
            action_set({'output': resp})
        else:
            action_fail('API call on fortios failed reason:'+resp)
    remove_state('actions.conf-port')
    status_set('active','alive')


