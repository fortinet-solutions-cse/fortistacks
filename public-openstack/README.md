# Public OpenStack

After lot of experiments and tries we recommend using Citycloud as a public openstack for testing Fortinet products.
The scripts and demo availbale here are compatible with private openstacks (see ubuntu-openstack folder) or Citycloud.
They can easily be adapted to other environment. Pull request appreciated.


## CityCloud

Once you created an account on 
Go to https://citycontrolpanel.com/openstack#openstack_api_access line with user there a wheel on the right you can download rc file to get cli access
Download your credentials in a openstack.rc type of file. (Name does not matter)

Add the following to your .rc file:
```shell
export OS_FLAVOR=1C-1GB
export EXT_NET=ext-net
```

### Limitations 

- No horizon gui (for now) but a Gui
- Can't create your own flavors (not a problem)

# Fortistack client

In order to run Fortistacks scripts you will need your own Ubunut16.04 image.
It can be a VM or your own laptop.

We provide a Docker image for portability:
 
Copy your .rc file with the openstack credentials in fortistacks folder.

From fortistacks folder:
```shell
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/root/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t thomnico/fortinet-cse:fortistacks-cli-1.2
```
Or adapt to your folder layout, check README-DockerClient.md for details on building using it.

Once you are logged in this Ubuntu environment source your openstack.rc file and run:
````shell
cd public-openstack
./configure-openstack
````

This will validate that you have the right tools installed, create a router, floating-ips, a mgmt network and subnet.
It is required by the other parts of the project.

To keep your cost down we provide a script to destroy ressources automatically:
````shell
cd public-openstack
./unconfigure.sh
````

# Cloud images 

For fortigate/fortios go to https://support.fortinet.com and download the last fortigate VM image.
Those scripts start with 5.6.3 (previous version may work)

```shell
openstack image create fgt56 --file fortios.qcow2 --disk-format qcow2 --container-format bare
```
Will be taken care of by the minipoc-deploy.sh script.

# Cloudify image

Get the qcow2 image from here: http://repository.cloudifysource.org/cloudify/4.2.0/ga-release/cloudify-manager-4.2ga.qcow2 
It is a 5G file.

Then onboard on openstack
```shell
openstack image create cfy-manager4.2 --file Downloads/cloudify-manager-4.2ga.qcow2 --disk-format qcow2 --container-format bare
```
