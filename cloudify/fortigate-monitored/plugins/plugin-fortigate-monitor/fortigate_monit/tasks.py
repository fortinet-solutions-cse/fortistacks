#########
# Copyright (c) 2014 GigaSpaces Technologies Ltd. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.

import os
from configobj import ConfigObj
from shutil import rmtree
from tempfile import mkdtemp

from cloudify.decorators import operation

from cloudify import constants
from cloudify import ctx

CONFIG_NAME = 'fgtmonit.conf'
PID_NAME = 'fgtmonit.pid'
DEFAULT_INTERVAL = 10
DEFAULT_TIMEOUT = 10

DEFAULT_HANDLERS = {
    'cloudify_handler.cloudify.CloudifyHandler': {
        'config': {
            'server': 'localhost',
            'port': constants.BROKER_PORT_SSL,
            'topic_exchange': 'cloudify-monitoring',
            'vhost': '/',
            'user': 'guest',
            'password': 'guest',
        }
    }
}


@operation
def install(**kwargs):
    fgtmonit_root = _calc_workdir()
    # we're adding a property which is set during runtime to the runtime
    # properties of that specific node instance
    ctx.instance.runtime_properties['fgtmonit_root'] = fgtmonit_root

    command = 'cd {0}; python setup.py install  > /dev/null 2>&1'.format(fgtmonit_root)
    ctx.logger.info('install using : {0}'.format(command))
    os.system(command)


@operation
def start(**kwargs):
    # we're adding a property which is set during runtime to the runtime
    # properties of that specific node instance
    fgtmonit_root = ctx.instance.runtime_properties['fgtmonit_root']

    # create an empty file to stop if can't be done right at beginning
    # with open(os.path.join(fgtmonit_root, 'fgtmonit.yaml'), 'w') as f:
    f.write('')

    ctx.instance.runtime_properties['fgtmonit_conf'] = os.path.join(fgtmonit_root, 'fgtmonit.yaml')
    # FGTMONIT_CONF_FILE env variable is where to find the config file for fgtmonit.py
    os.putenv(FGTMONIT_CONF_FILE, os.path.join(fgtmonit_root, 'fgtmonit.yaml'))
    command = 'cd {0}; ./fgtmonit.py start  > /dev/null 2>&1'.format(fgtmonit_root)
    ctx.logger.info('Starting fgtmonit server using: {0}'.format(command))
    os.system(command)


@operation
def stop(**kwargs):
    # setting this runtime property allowed us to refer to properties which
    # are set during runtime from different time in the node instance's lifecycle
    fgtmonit_root = ctx.instance.runtime_properties['fgtmonit_root']
    try:
        command = 'cd {0}; ./fgtmonit.py stop  > /dev/null 2>&1'.format(fgtmonit_root)
        ctx.logger.info('Stopping fgtmonit server using: {0}'.format(command))
        os.system(command)
    except IOError:
        ctx.logger.info('fgtmonit server is not running!')


def restart(self):
    fgtmonit_root = ctx.instance.runtime_properties['fgtmonit_root']

    # FGTMONIT_CONF_FILE env variable is where to find the config file for fgtmonit.py
    os.putenv(FGTMONIT_CONF_FILE, ctx.instance.runtime_properties['fgtmonit_conf'])

    try:
        command = 'cd {0}; ./fgtmonit.py restart  > /dev/null 2>&1'.format(fgtmonit_root)
        ctx.logger.info('Restart fgtmonit server using: {0}'.format(command))
        os.system(command)
    except IOError:
        ctx.logger.info('fgtmonit server is not running!')


@operation
def fortigate_add(**kwargs):
    ## get the config from cloudify target and restart
    conf = ctx.instance.runtime_properties['fgtmonit_conf']
    ## write changes

    ##
    restart(self)


@operation
def fortigate_remove(**kwargs):
    ## get the config from cloudify target and restart
    conf = ctx.instance.runtime_properties['fgtmonit_conf']
    ## write changes

    ##
    restart(self)


def write_config(path, properties):
    """
    write config file to path with properties. if file exists, properties
    will be appended
    """
    config = ConfigObj(infile=path)
    for key, value in properties.items():
        config[key] = value
    config.write()


def get_host_ctx(ctx):
    """
    helper method ..
    """
    host_id = get_host_id(ctx)
    host_node_instance = ctx._endpoint.get_node_instance(host_id)
    return host_node_instance


def get_host_id(ctx):
    ctx.instance._get_node_instance_if_needed()
    return ctx.instance._node_instance.host_id


def delete_path(ctx, path):
    try:
        if os.path.isdir(path):
            rmtree(path)
        else:
            os.remove(path)
    except OSError as e:
        if e.errno == os.errno.ENOENT:
            ctx.logger.info("Couldn't delete path: "
                            "{0}, already doesn't exist".format(path))
        else:
            raise


#        prefix = ctx.plugin.prefix

def _calc_workdir():
    # Used to check if we are inside an agent environment
    celery_workdir = os.environ.get('CELERY_WORK_DIR')
    if celery_workdir:
        try:
            workdir = ctx.plugin.workdir
        except AttributeError:
            # Support older versions of cloudify-plugins-common
            workdir = os.path.join(celery_workdir, 'fgtmonit')
    else:  # Used by tests
        workdir = mkdtemp(prefix='fortigate-monitoring-')
    return workdir


def _get_agent_name(ctx):
    return ctx.instance.runtime_properties['cloudify_agent']['name']


def _get_service_name(ctx):
    return 'fgtmonit_{0}'.format(_get_agent_name(ctx))

# TODO: review the diamond conf to put fgtmonit in a proper service conf (systemctl)
