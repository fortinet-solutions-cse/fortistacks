#!/usr/bin/env python
#License Apachev2
### BEGIN INIT INFO
# Provides:          fortigate_monit
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start fortigate_monit on boot
# Description:       Start fortigate_monit on boot
### END INIT INFO


import logging
from packaging.version import Version

import yaml
import sys
import os

from logging.handlers import SysLogHandler
import time
from service import find_syslog, Service

from cloudify import (
    broker_config,
    cluster,
    utils,
)
try:
    import pika
except ImportError:
    pika = None

try:
    from fortiosapi import FortiOSAPI
    fortiosapi = "present"
    # define a variable to avoid stacktraces
except ImportError:
    fortiosapi = None

#formatter = logging.Formatter(
#    '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
#logger = logging.getLogger('fortiosapi')
#hdlr = logging.FileHandler('fortigatecollector.log')
#hdlr.setFormatter(formatter)
#logger.addHandler(hdlr)
#logger.setLevel(logging.DEBUG)
fortigateList = []

class MyService(Service):
    def __init__(self, *args, **kwargs):
        super(MyService, self).__init__(*args, **kwargs)
        self.logger.addHandler(SysLogHandler(address=find_syslog(),
                               facility=SysLogHandler.LOG_DAEMON))
        self.logger.setLevel(logging.INFO)
        self.fortigateList = []
        self.conf = yaml

    def bindtocfymq(self):
        """
               Create  socket and bind (we override the default implementation
              to set auto_delete=True)
        """
        credentials = pika.PlainCredentials(self.user, self.password)

        ssl_enabled = broker_config.broker_ssl_enabled

        ssl_options = utils.internal.get_broker_ssl_options(
            ssl_enabled=ssl_enabled,
            cert_path=broker_config.broker_cert_path,
        )
        # Get the cluster host if applicable
        cluster_settings = cluster.get_cluster_amqp_settings()
        broker_host = cluster_settings.get(
            'amqp_host',
            broker_config.broker_hostname
        )

        params = pika.ConnectionParameters(credentials=credentials,
                                           host=broker_host,
                                           virtual_host=self.vhost,
                                           port=self.port,
                                           ssl=ssl_enabled,
                                           ssl_options=ssl_options)

        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()
        self.channel.exchange_declare(exchange=self.topic_exchange,
                                      exchange_type="topic",
                                      auto_delete=True,
                                      durable=False,
                                      internal=False)

    def configload(self):
        # fortigateList is a list of fortiosAPI object to ease the parsing and keep the session up
        # Change in yaml format the configfile
        conffile = os.getenv('FGTMONIT_CONF_FILE', "fgtmonit.yaml")
        self.conf = yaml.load(open(conffile, 'r'))
        if fortiosapi is None:
            self.logger.error("Unable to import fortiosapi python module")
            exit(2)
        # config is now a list that we map to fortigateList list of objects.

        #Brutal option logout all and reconstruct
        for fgt in fortigateList:
            self.logger.info("Logout from %s", fgt)
            fgt.logout()
            fortigateList.remove(fgt)
        self.logger.info("FortigateList should be empty is %s", fortigateList)

        for fgtc in self.conf:
            print(self.conf[fgtc]['hostname'])
            self.logger.info("device : %s", self.conf[fgtc])
            # create a FortiosAPI objects in the list:
            fortigateList.append(FortiOSAPI())
            if self.conf[fgtc]['https'] == 'false':
                fortigateList[-1].https('off')
            else:
                fortigateList[-1].https('on')
            try:
                fortigateList[-1].login(self.conf[fgtc]['hostname'],
                                    self.conf[fgtc]['user'],
                                    self.conf[fgtc]['password'])
                self.logger.info("Login successfull for : %s", self.conf[fgtc]['hostname'])
            except:
                # if failing login remove from list.
                fortigateList.remove(fortigateList[-1])
            # Log
        self.logger.info("FortigateList is %s", fortigateList)

# will need to do a much more complex service to be able to call a change on the running deamon
# #keep it simple for now
#    def reload(self):
#        pid = self.get_pid()
#        if pid:
#            self.configload()
#

    def publish(self, host, name, metric):
        self.logger.info("host: %s", host)
        for c in self.conf:
            if self.conf[c]['hostname'] == host:
                fgtid = c
        self.logger.info("host: %s, name %s: metric : %s", fgtid, name, metric)


    def run(self):
        #off by now"bindtocfymq()
        while not self.got_sigterm():
            self.logger.info("Collecting from %s", fortigateList)
            for fgt in fortigateList:
                metrics = fgt.monitor('system', 'vdom-resource',
                                      mkey='select', vdom='root')['results']
                # TODO allow different vdom per devices
                self.logger.debug("rest api collected is %s", metrics)
                # try to change the hostname in the output

                self.publish(fgt.host,"cpu", metrics['cpu'])
                self.publish(fgt.host,"memory", metrics['memory'])
                self.publish(fgt.host,"setup_rate", metrics['setup_rate'])
                if Version(fgt.get_version()) > Version('5.6'):
                    self.publish(fgt.host,"sessions", metrics['session']['current_usage'])
                else:
                    self.publish(fgt.host,"sessions", metrics['sessions'])
            self.logger.info("resting")
            time.sleep(3)

if __name__ == '__main__':

    if len(sys.argv) != 2:
        sys.exit('Syntax: %s COMMAND' % sys.argv[0])

    cmd = sys.argv[1].lower()
    service = MyService('my_service', pid_dir='/tmp')

    if cmd == 'start':
        service.configload()
        service.start()
    elif cmd == 'stop':
        service.stop()
    elif cmd == 'restart':
        try:
            service.stop()
        except:
            pass
        while service.is_running():
            time.sleep(0.2)
        service.configload()
        service.start()
    elif cmd == 'status':
        if service.is_running():
            print "Service is running."
        else:
            print "Service is not running."
    else:
        sys.exit('Unknown command "%s".' % cmd)

