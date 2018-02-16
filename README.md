# Fortistacks #

This Fortinet project goal is to provide an automated NfV stack and examples to allow the testing of Fortinet products on real clouds and point interaction with orchestrators.

The scripts are supposed to run on an Ubuntu with root access. 

For stable versions of this project refer to :

https://github.com/fortinet-solutions-cse/fortistacks/releases to find
the release you like. The master branch can contain work in progress.

## What you will find here (pre release 1.2)

In the different directories you will find the following parts, read the README in each folder for details:
- <b>fortistacks </b> Script to turn a vanilla Ubuntu with empty partition into a system ready for fortistack. Can be ignored if using public or your own openstack.

- <b>ubuntu-openstack </b> set of scripts to install a fully fonctionnal openstack on 1 machine and use it later as the default VIM. Rely on you running the fortistacks script first. 

- <b>public-openstack </b> This section will configure you CityCloud openstack to work with this project. 

- <b>mini-poc</b> Is the name of a simple scenario (2 networks) 2 generic VMs 1 fortigate in between. All with floating ips so that one can connect to them and generate traffic, see it/block it. This same simple scenario is then declined with the the different approach. It contains the important points to pay attention to while deploying a fortigate/fortios.

- <b>fortigate/fortios </b> Those are very similar only the fortigate/fortios are highlighted. Target is at least 5.6.3 or 5.4.5 which makes config_drive optionnal. There is script in bash(read it to see the cli) and heat templates

- <b>cloudify </b> In this folder you will deploy a Cloudify-manager (on lxc locally or vm if public) autoconfigure for using opentack then have the blueprint to use it.
 
- <b>osm </b> In this folder you will deploy an OpenSource MANO instance (on lxc locally or vm if public) autoconfigure for using opentack then have the descriptors to use it.
 


The goal is to provide an open environment for experimenting, making
functionnal demos on the road. Develop share Fortinet based demos.

This project is opensource and based under Apachev2 license. Every
contribution is supposed to respect that. Don't put your company IP in
here .. it is bad.

## Requirement ##

(Please have a look to this video showing installation and execution steps:  https://youtu.be/0y38B61FTSk)

Install a fresh ubuntu 16.04 with a 100G available free linux
partition or disk.
On a single disk machine go in advance mode for disk to ensure
you create a 100G minimum free partition. (Can be done after install
for power users).

## Run this scripts ##

on your newly installed Ubuntu:
```shell

git clone https://github.com/fortinet-solutions-cse/fortistacks.git

cd fortistacks

./fortistacks -p /dev/sdaX sudoers install desktop
```

Be sure to replace /dev/sdaX with a free to use partition.

## What's now ##

Now you have a lxd ready ubuntu, sudo without passwd and access it
from MacOSX and windows vnc://<IP of fortistacksxs>


Every other step is in its onw folder with a README.md in it.

The first instance of this project contains a openstack mitaka on
ubuntu you can use:

`cd ubuntu-openstack`
`./deploy.sh`
will take some time (like 40mins) monitor with
`watch -c juju status --color`

Fortigate/Fortios folders deal with fortinet products on openstack/heat.

Cloudify deal with a full MANO implementation and blueprint.

Check the README in every folder for details. Those can be used on public or personnal real openstack with minimum adaptation.

##For v1.1
A full explanation/follow along video is available here: https://youtu.be/0y38B61FTSk
For v1.0 :
Previous version https://vimeo.com/215625341 (to see rift.io)

Is a collection of scripts and pre defined setups for running a full
stack of software (openstack, container, later kubernetes, etc..)
orchestrators.

It is based on LXC containers (LXD) on ubuntu 16.04 minimum that
provides a way to simulate 20+ machines in a beefy vm, a small machine
like intel nuc or others.
