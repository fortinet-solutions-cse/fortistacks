If not using an Ubuntu machine:
you can use Docker like this example:

```shell
$ docker run -v $HOME/src/fortistacks/:/fortistack/ -v $HOME/.ssh:/root/.ssh/ --rm -i -t ubuntu:16.04 
 ```

But won't be able to have your own OpenStack then.

To build the Docker you need:
apt update 
apt install python-pip git zile byobu wget sudo
pip install python-novaclient==9.1.1 python-openstackclient

#need to do a Dockerfile (fortistacks cli)
Check dockerfile
```shell
$ docker run -v $HOME/src/fortistacks/:/fortistack/ -v $HOME/.ssh:/root/.ssh/ --rm -i -t fortistack-cli  --name fortistack-cli:1.0  -h fortistack-cli 
 ```

Ensure to have the citycloud rc environment variable in the file