# coding=utf-8

"""
A collector for Fortinet Fortigate 

#### Dependencies

 * fortiosapi (on pypi)

#### Configuring FortigateCollector

The configuration format is as follow:
        # Options for FortigatesCollector
        path = fortinet
        interval = 9

        [devices]

        [[fgt1]]
        hostname = 10.10.10.125
        user = admin
        password = toto
        vdom = root
        https = true

        [[fgt2]]
        hostname = 10.10.10.74
        user = admin
        password =
        vdom = root
        https = false

Allowing to monitor multiple fortigate devices

For testing collectors etc refer to the example collector documentation.

Diamond looks for collectors in /usr/lib/diamond/collectors/ (on Ubuntu). By
default diamond will invoke the *collect* method every 60 seconds.

Diamond collectors that require a separate configuration file should place a
.cfg file in /etc/diamond/collectors/.
The configuration file name should match the name of the diamond collector
class.  For example, a collector called
*FortigateCollector.FortigateCollector* could have its configuration file placed in
/etc/diamond/collectors/FortigateCollector.cfg.

"""

import logging
from packaging.version import Version

import diamond.collector

try:
    from fortiosapi import FortiOSAPI
    fortiosapi = "present"
    # define a variable to avoid stacktraces
except ImportError:
    fortiosapi = None
formatter = logging.Formatter(
    '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
logger = logging.getLogger('fortiosapi')
hdlr = logging.FileHandler('fortigatecollector.log')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.DEBUG)

fortigateList = []

class FortigateCollector(diamond.collector.Collector):

    def get_default_config_help(self):
        config_help = super(FortigateCollector, self).get_default_config_help()
        config_help.update({
            '[[fortigate1]]'
            'hostname': 'Hostname or IP to collect from',
            'user': 'Username',
            'password': 'Password',
            'https': 'True or False if using http or https (http for eval)',
            'vdom': ''
        })
        return config_help

    def get_default_config(self):
        """
        Returns the default collector settings
        """
        config = super(FortigateCollector, self).get_default_config()
        config.update({
        })

        return config

    def __init__(self, *args, **kwargs):
        super(FortigateCollector, self).__init__(*args, **kwargs)
        if fortiosapi is None:
            self.log.error("Unable to import fortiosapi python module")
            exit(2)
        # config is now a list that we map to fortigateList list of objects.
        for fgtconf in self.config['devices']:
            self.log.info("device : %s", self.config['devices'][fgtconf])
            # create a FortiosAPI objects in the list:
            fortigateList.append(FortiOSAPI())
            if self.config['devices'][fgtconf]['https'] == 'false':
                fortigateList[-1].https('off')
            else:
                fortigateList[-1].https('on')
            fortigateList[-1].login(self.config['devices'][fgtconf]['hostname'],
                                    self.config['devices'][fgtconf]['user'],
                                    self.config['devices'][fgtconf]['password'])
            # Log
            self.log.info("Login successfull for : %s", self.config['devices'][fgtconf]['hostname'])


    def collect(self):
        """
        Overrides the Collector.collect method
        """
        for fgt in fortigateList:
            metrics = fgt.monitor('system', 'vdom-resource',
                                  mkey='select', vdom='root')['results']
            # TODO allow different vdom per devices
            # try to change the hostname in the output
            self.config['hostname'] = fgt.host
            self.publish("cpu", metrics['cpu'])
            self.publish("memory", metrics['memory'])
            self.publish("setup_rate", metrics['setup_rate'])
            if Version(fgt.get_version()) > Version('5.6'):
                self.publish("sessions", metrics['session']['current_usage'])
            else:
                self.publish("sessions", metrics['sessions'])
