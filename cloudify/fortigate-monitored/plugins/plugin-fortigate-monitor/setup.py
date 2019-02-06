from setuptools import setup

setup(
    name='fortigate-monitor',
    version='0.1',
    author='Fortinet',
    author_email='nthomas@fortinet.com',
    description='Cloudify Fortigates monitoring plugin using mq diretly',
    packages=['fortigate_monit', 'cloudify_handler'],
    package_data={
        'fortigate_monit': ['resources/fgtmonit.py']
    },
    license='LICENSE',
    install_requires=['cloudify-plugins-common>=4.0',
                      'ConfigObj==5.0.6',
                      'psutil==2.1.1',
                      'fortiosapi',
                      'service'],
)
