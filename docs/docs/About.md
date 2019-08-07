# ABOUT

This  project is a collection of solutions examples using Fortinet (mainly Fortigate/Fortios) VMs on any stack/cloud etc..


This version 2 also provide more advanced examples for secure sdwan and scalability. Those requires Fortimanager.

To correctly get the referenced submodules please use the --recursive option of git clone like this:
```bash
git clone https://github.com/fortinet-solutions-cse/fortistacks.git --recursive
```
When updating to last version use:
```bash
git pull --recurse-submodule
```

The scripts are made to run on an Ubuntu with sudo access. 

If you don't have a native Ubuntu or want keep things separated use the Docker based CLI:

Copy your .rc file with the openstack credentials in fortistacks folder.

From fortistacks folder:
```shell
cd fortistacks
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortinetsolutioncse/fortistacks-cli
```

See the [README-Dockerclient.md](README-Dockerclient.md) for running on external Openstack on any client.

To achieve this we propose here a tested public openstack with CityCloud or a personnal openstack in a box (Ubuntu)

## Architecture/prerequisites ##

### OpenStack

### Orchestration

### Fortinet image and demo files

## Mini Proof of Concept ##

Prerequisite: run [```./configure-openstack```](public-openstack/configure-openstack) script prior to deploy mini-poc with different methods.

Mini-poc is used to refer to deploying 2 Ubuntu VMs with iperf, Apache, etc.. to be able to generate traffic.
2 networks left and right.
1 fortigate or fortios 
All have floating ips on a predefined mgmt network
As described here:


        ===========================================================
            |                     |    Management/floating ips   |
            |                     |                              |
       .----v-----.               |                              |
       | trafleft |               |                              |
       |  Ubuntu  |               |                              |
       '----------'               |                              |
             |                    |                              |
             v                    |                              |
        .-,(  ),-.          .-----v-----.        .-,(  ),-.      |
     .-(          )-.       | Fortigate |     .-(          )-.   |
    (      left      )----->|     vm    |--->(      right      ) |
     '-(          ).-'      '-----------'     '-(          ).-'  |
         '-.( ).-'                                '-.( ).-'      |
                                                      <-------.  |
                                                              |  v
                                                        .-----------.
                                                        | trafright |
                                                        |   Ubuntu  |
                                                        '-----------'


The goal is to offer an easy access to all parts and being able to experiment with Fortinet products on Openstack.
There is little explanations are all the code is available. We may put explanations in comments though.

This same result is then achieved with different tools: script, heat template, cloudify blueprint, osm VNFd.

## What you will find here

In the different directories you will find the following parts, read the README in each folder for details:

- <b>[public-openstack](public-openstack)</b> This section will configure you CityCloud openstack to work with this project. 

- <b>fortigate/fortios </b> Those are very similar only the fortigate/fortios are highlighted. Target is at least 5.6.3 or 5.4.5 which makes config_drive optionnal. There is script in bash(read it to see the cli) and heat templates

- <b>cloudify </b> In this folder you will deploy a Cloudify-manager (on lxc locally or vm if public) autoconfigure for using opentack then have the blueprint to use it.
 
- <b>osm </b> In this folder you will deploy an OpenSource MANO instance (on lxc locally or vm if public) autoconfigure for using opentack then have the descriptors to use it.

- <b>fortistacks </b> Script to turn a vanilla Ubuntu with empty partition into a system ready for fortistack. Can be ignored if using public or your own openstack.

- <b>ubuntu-openstack </b> set of scripts to install a fully fonctionnal openstack on 1 machine and use it later as the default VIM. Rely on you running the fortistacks script first. 
 
## What do you need (choices)

- An Openstack:
  - Public ($) use Citycloud: create and account and go to public-openstack folder  
  - Private create you own and go to ubuntu-openstack folder

- Fortigate/fortios images check fortigate and fortios folder for scripted and heat examples.
- MANO: 
  - Cloudify folder depending on you openstack choice deploy manager then use the blueprints.
  - OSM/Rift.io same as above

This project is opensource and based under Apachev2 license. Every contribution is supposed to respect that. Don't put your company IP in here .. it is bad.


## Videos

Fortistacks1.2 on Public openstack : https://youtu.be/Zp6CCEbJiUU

If you want to install your own openstack and use the same (on 1 machine) refer to 
 Fortistacks1.1  https://youtu.be/0y38B61FTSk the video applies to version 1.2.

## Previous versions
For stable versions of this project refer to :

https://github.com/fortinet-solutions-cse/fortistacks/releases to find
the release you like. The master branch can contain work in progress.

