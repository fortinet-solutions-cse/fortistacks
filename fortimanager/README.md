# example cli to manually deploy:


```
openstack server create --image "FMG642" fmg642 --flavor $OS_FLAVOR --nic net-id=mgmt,v4-fixed-ip=192.168.1.99 --block-device-mapping vdb=fmg-log1 --user-data fmg-userdata.txt --config-drive=true
```

See the heat template for an example.
