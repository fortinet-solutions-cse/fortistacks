# Fortistacks client on Docker (any macine)

Using a Docker image will require that you already have access to an Openstack. 
The ubuntu-openstacks scripts run only on native Ubuntu with virtualization available.

# Quick start

Copy your .rc file with the openstack credentials in fortistacks folder.

From fortistacks folder:
```shell
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t thomnico/fortinet-cse:fortistacks-cli-1.3
```
Or adapt to your folder layout.

Once started cd /fortistacks/ and simply source your RC-file than you get from https://citycontrolpanel.com/openstack#openstack_api_access (link in the parameters of the user)
Be sure to add:
```shell
export OS_FLAVOR=1C-1GB
export EXT_NET=ext-net
```
At the end of your RC-file first.


# Hackers/curious 
Check Dockerfile in this folder to see how it is done.
Have to use pinpoint version due to weeks long bugs in openstack clients.

```shell
$ docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortistacks-cli:1.3 
 ```

