# Fortistacks details

Please check [Fortistacks 2.0](Quickstart.md) for a global explanation.

#Scripts

The fortistacks scripts/examples are built to be indempotent, you can re-run them without duplicating the result. 

The scripts are made to run on an Ubuntu with sudo access. We provide the Docker image for a pre-determined environment.
You are free to adapt, run on other environement (those are mainly bash/python), but please reproduce with the Docker 
image before raiing a bug. 


See the [Dockerclient](README-Dockerclient.md) for running on external Openstack on any client.

# Working Examples

In every folder under the overall project you will find examples you can use directly with your customed build Stack 
(Openstack and/or MANO). In theory only the parameter file should be changed.


## What you will find here

In the different directories you will find the following parts, read the README in each folder for details:

- <b>openstack</b> This section will configure you CityCloud openstack to work with this project. 

- <b>fortigate/fortios </b> Those are very similar only the fortigate/fortios are highlighted. Target is at least 5.6.3 or 5.4.5 which makes config_drive optionnal. There is script in bash(read it to see the cli) and heat templates

- <b>cloudify </b> In this folder you will deploy a Cloudify-manager (on lxc locally or vm if public) autoconfigure for using opentack then have the blueprint to use it.
 
- <b>osm </b> In this folder you will deploy an OpenSource MANO instance (on lxc locally or vm if public) autoconfigure for using opentack then have the descriptors to use it.

- <b>fortistacks </b> Script to turn a vanilla Ubuntu with empty partition into a system ready for fortistack. Can be ignored if using public or your own openstack.

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

A youtube playlist will contain follow along video to be hands on [Fortistacks](https://www.youtube.com/playlist?list=PL78t125b9Q2YWfB4nre9NRTrerA-awaSo)

## Previous versions
For stable versions of this project refer to :

https://github.com/fortinet-solutions-cse/fortistacks/releases to find
the release you like. The master branch will evolve continuously.

Fortistacks1.2 on Public openstack : https://youtu.be/Zp6CCEbJiUU

If you want to install your own openstack and use the same (on 1 machine) refer to 
 Fortistacks1.1  https://youtu.be/0y38B61FTSk the video applies to version 1.2.

