#!/bin/bash -xe

#Script to destroy all lxc instances in case it is needed (juju disconnected for exmaple)
for l in `lxc list  --format json | jq .[].name --raw-output`
 do
  lxc delete $l --force
 done
