# Fortgate monitor Plugin

Plugin to  monitor multiple fortigate and push collected 
info directly to mq instead of relying on Diamond.

Inspired by Diamond plugin.

Designed to be run on a separate VM from Manager.

Can try to use python-service and inotify to reread config
Should do a config.d/ to use removal.

Can output in a file same type of metrics as Diamond or install my Diamond here..
 
 The cloudify handler is diamond to mq