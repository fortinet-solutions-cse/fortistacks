#  Fortistacks 2.0

Fortistacks is a collection of examples, scripts and documentation to use [Fortinet](http://fortinet.com) products in 
Clouds/fully automated environments. 

Initial focus is on OpenStack, more to come.

# Quickstart

For those who wants direct hands on, follow me instruction. More explanation in the Fortistacks section.

## Pre requisite
* Openstack and API access to openstack. You are supposed to have the .rc file corresponding to your environement.
      
      - We extensibely use private OpenStack and [Citycloud](http://citycloud.com/) (public)
      
      - Previous Fortistacks came with an all in one openstack installation. We recommend [OSA](https://docs.openstack.org/openstack-ansible/latest/) if you prefer that.
      
* Docker installed on you host
* git cli
* an ssh key generated in you home environement (can be done later in Docker)

##
To correctly get the referenced submodules please use the --recursive option of git clone like this:
```bash
git clone https://github.com/fortinet-solutions-cse/fortistacks.git --recursive
```

Copy your .rc file with the openstack credentials in fortistacks folder.
Add the following line:
````bash
export OS_FLAVOR=1C-1GB
export EXT_NET=ext-net
````
Adapt to your environment those variables are for a Citycloud deployment.
If unset the values will be "m1.small" and "ext_net"


From fortistacks folder:
```shell
cd fortistacks
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortinetsolutioncse/fortistacks-cli
```

source you .rc file
```bash
. myopenstackcreds.rc
openstack image list
```

The list command must return the list of available image. If this is the case your fortistacks cli is ready.
If not review/debug all the previous points.

##create the default openstack objects.
```bash
cd openstack/
 ./configure-openstack
```

This will create the mgmt network, a provider-router, upload default ssh key and configure security group.
The examples in this project relies on this to be available.

##Updating
To get the latest enhancements: 
```bash
git pull --recurse-submodule
docker pull fortinetsolutioncse/fortistacks-cli
```

# What now ?

You have setup the basic interaction with your Openstack, you can now experiment with Fortigate product 
and automation (MANO) environment.
The different working demos are in self explanatory directory. The examples are build to be easily adaptable to your 
environment (fortistacks-cli in docker is an helper not mandatory)
