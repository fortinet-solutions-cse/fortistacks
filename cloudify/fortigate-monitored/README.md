# cloudify-diamond-fortiget-extension
An extension to the diamond plugin that adds support for Fortigate monitoring.

## Usage

Fortigate does not allow agent installation (we are the firewall not an app).
So plugin must run on manager and use the fortinet API.

Inspired by [Diamond SNMP Integration](http://getcloudify.org/guide/3.2/reference-diamond-snmp-integration.html)


Work in progress does not work yet (diamond installation issue)
## Ref documentation for development
[Create your plugin](http://docs.getcloudify.org/4.2.0/plugins/creating-your-own-plugin/)

[plugin specs](http://docs.getcloudify.org/4.2.0/blueprints/spec-plugins/)

[Using plugin](http://docs.getcloudify.org/4.2.0/plugins/using-plugins/)

Goal is to create an automated transit : (http://cookbook.fortinet.com/fgsp-expert-56/)