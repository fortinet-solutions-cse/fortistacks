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

import json


def jsonify(metric):
    deployment_id = metric.getPathPrefix()
    host, node_name, node_id = metric.host.split('.')
    name = metric.getCollectorPath()
    raw_metric_path = metric.getMetricPath()
    path = raw_metric_path.replace('.', '_')
    metric_value = float(metric.value)
    metric_type = metric.metric_type
    time = metric.timestamp
    service = '.'.join([
        deployment_id,
        node_name,
        node_id,
        name,
        raw_metric_path
    ])

    output = {
        # Node instance id
        'node_id': node_id,

        # Node id
        'node_name': node_name,

        # Deployment id
        'deployment_id': deployment_id,

        # Metric name (e.g. cpu)
        'name': name,

        # Sub-metric name (e.g. avg)
        'path': path,

        # The actual metric value
        'metric': metric_value,

        # Metric unit
        'unit': '',

        # Metric type (gauge, counter, etc...)
        'type': metric_type,

        # Host instance id
        'host': host,

        # The full metric name (
        # e.g. deployment_id.node_id.node_instance_id.metric)
        'service': service,

        # epoch timestamp of the metric
        'time': time,
    }
    return json.dumps(output)
