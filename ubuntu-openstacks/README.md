# This folder contains how to deploy openstack on fortistacks

To deploy mitaka:

./deploy-openstack

This script will wait for completion.

You follow with juju gui or watch -c juju status --color

Get the linux images to upload:
./get-cloud-images

Once done:
./configure-openstack

You openstack will all set.

Use juju status openstack-dashboard to find the IP adress of the openstack GUI.
Can find it in juju gui.
