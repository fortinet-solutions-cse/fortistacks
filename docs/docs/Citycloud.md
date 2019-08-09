# Public OpenStack

After lot of experiments and tries we recommend using Citycloud as a public openstack for testing Fortinet products.
The scripts and demo availbale here are compatible with private openstacks or Citycloud.
They can easily be adapted to other environment. Pull request appreciated.


## CityCloud

Once you created an account on 
Go to https://citycontrolpanel.com/openstack#openstack_api_access line with user there a wheel on the right you can 
download rc file to get cli access
Download your credentials in a openstack.rc type of file. (Name does not matter)

Add the following to your .rc file:
```shell
export OS_FLAVOR=1C-1GB
export EXT_NET=ext-net
```
List of Regions: "Sto2 Lon1 Fra1 Buf1 La1 Kna1"

### Limitations 

- No horizon gui (for now) but a Gui
- Can't create your own flavors (not a problem)

### Spending
To keep your cost down we provide a script to destroy ressources automatically:
````shell
cd public-openstack
./unconfigure.sh
````

## Cloud images 

For fortigate/fortios go to https://support.fortinet.com and download the last fortigate VM image.
Those scripts start with 5.6.3 (previous version may work)
