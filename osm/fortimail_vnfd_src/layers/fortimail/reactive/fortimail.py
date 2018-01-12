from charms.reactive import when, when_not, set_state


@when_not('fortimail.installed')
def install_fortimail():
    # Do your setup here.
    #
    # If your charm has other dependencies before it can install,
    # add those as @when() clauses above., or as additional @when()
    # decorated handlers below
    #
    # See the following for information about reactive charms:
    #
    #  * https://jujucharms.com/docs/devel/developer-getting-started
    #  * https://github.com/juju-solutions/layer-basic#overview
    #
    set_state('fortimail.installed')


@when('actions.create-domain')
def create_domain():
    err = ''
    try:
        cmd = ""
        result, err = charms.sshproxy._run(cmd)
    except:
        action_fail('command failed:' + err)
    else:
        action_set({'outout': result})
    finally:
        remove_flag('actions.create-domain')

@when('actions.delete-domain')
def create_domain():
    err = ''
    try:
        cmd = ""
        result, err = charms.sshproxy._run(cmd)
    except:
        action_fail('command failed:' + err)
    else:
        action_set({'outout': result})
    finally:
        remove_flag('actions.delete-domain')

@when('actions.get-administrative-resource')
def get_administrative_resource():
    err = ''
    try:
        cmd = ""
        result, err = charms.sshproxy._run(cmd)
    except:
        action_fail('command failed:' + err)
    else:
        action_set({'outout': result})
    finally:
        remove_flag('actions.get-administrative-resource')
