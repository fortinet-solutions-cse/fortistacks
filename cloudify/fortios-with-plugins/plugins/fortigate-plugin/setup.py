# #######
# Copyright (c) 2018 Fortinet Ltd. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    * See the License for the specific language governing permissions and
#    * limitations under the License.
'''Fortinet plugin package config'''

from setuptools import setup

setup(
    name='fortigate-plugin',
    description='A Cloudify plugin for Fortigate and Fortios NFV orchestration',
    version='0.1',
    license='Apache v2',
    zip_safe=False,

    # This must correspond to the actual packages in the plugin.
    packages=['fortigate']
    # cmdclass={'install': CustomInstall},

    install_requires=[
        # Necessary dependency for developing plugins, do not remove!
        "cloudify-plugins-common>=3.3.1",
        "paramiko", "fortiosapi",
    ]
)
