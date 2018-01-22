# From https://github.com/BrightcoveOS/Diamond/wiki/collectors-fortinetCollector
import diamond.collector

class FortinetCollector(diamond.collector.Collector):

    def collect(self):
        # Set Metric Path. By default it will be the collector's name (servers.hostname.fortinetCollector.my.fortinet.metric)
        self.config.update({
            'path':     'fortinet',
        })

        # Set Metric Name
        metric_name = "fortigate.cpu"

        # Set Metric Value
        metric_value = 42

        # Publish Metric
        self.publish(metric_name, metric_value)
        