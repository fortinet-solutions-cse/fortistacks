# Openstack Heat

Deploy the mini-poc scenario only using heat template. Read the yaml for details.

# Deploy
cli deploy
```
$ openstack stack create --template heat-minipoc.yaml mini-poc
```
on citycloud or with specific inputs file adapted to your NFVi provider
``` 
openstack stack create --template heat-minipoc.yaml mini-poc -e citycloud-env.yaml
```

The heat template is self contained you can also deploy using the heat gui.

# Floating ips

There is no floating ip usage by default to make the example more generic.
On public openstack you can apply [floating.patch]() with ```patch < .patch```
##follow
to follow execution:
 ```openstack stack event list mini-poc --follow
```
 To see the resutls IPs
 ```openstack stack show mini-poc -c outputs```