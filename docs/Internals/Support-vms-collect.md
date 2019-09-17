# Script to ease support

Exchanging with persons in the field we realize that collecting ALL the ressources related to a VM can be complex/time 
consuming.

We created this [support-vms-info.py](https://github.com/fortinet-solutions-cse/fortistacks/blob/master/openstack/support-vms-info.py) which works on any openstack VM.

Syntax
```bash
usage: support-vms-info.py [-h] [--verbosity] [-o [OUTFILE]] N [N ...]

positional arguments:
  N                     names of the VM to collect infos from

optional arguments:
  -h, --help            show this help message and exit
  --verbosity           show verbose msg of the openstack-client library
  -o [OUTFILE], --outfile [OUTFILE]
                        specify an output file instead of stdout
```

Source your openstack credentials and give a list of instances names or IDs.

The script will output on stdout (or file) a json with all the details of the related ressources.
This includes:
* ports
* networks, subnet
* console_output
* metadata
* image
* flavor
* security groups
* volume

# requirements

It you can run the openstack cli this script should work.
Need to source your openstack .rc, i.e. have environment variable setup properly.
