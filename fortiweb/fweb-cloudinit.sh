#!/bin/bash -ex
# /data/config should be mounted
# if TARGET_IP is set then add default rules
# may think of generic rules with base64
mkdir -p /data/config
cp /templates/sys_*  /data/config/
[ "$TARGET_IP" == "none" ] || ( envsubst < templates/defaut-conf.tmpl >> /data/config/sys_domain.root.conf )
cat /data/config/sys_domain.root.conf
gzip /data/config/sys_domain.root.conf