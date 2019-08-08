#!/bin/bash -ex

# release all floating ip not in use (save $$)
openstack floating ip list -f value -c "Floating IP Address" --status DOWN |xargs openstack floating ip delete 