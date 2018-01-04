# OSM Rel3 installation /usage 

Source your openstack credentials files.
On fortistacks it is in ~/nova.rc
Then run ./deploy.sh
wait a bit .. then you should be able to login on
https://10.10.10.x:8443/

do lxc list and look for the SO-ub (Rift-io) container IP
is 10.10.10.x 

login admin/admin

# build the packages
cd apache_vnf_src ; make
cd fortigate_vnfd_src; make

You will create vnfd.tar.gz package you can upload in rift.io
Then upload: FortigateApache_nsd.yaml

# More on http://osm.etsi.org

