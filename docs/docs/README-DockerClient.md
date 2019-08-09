# Fortistacks client on Docker (any macine)

Using a Docker image will require that you already have access to an Openstack. 

## Quick start

Copy your .rc file with the openstack credentials in fortistacks folder.

From fortistacks folder:
```shell
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortinetsolutioncse/fortistacks-cli
```
Or adapt to your folder layout.
If you want to persist this Docker:
```shell
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/  -i  --name fortistacks-cli  -h fortistacks-cli -t fortinetsolutioncse/fortistacks-cli
```
Then your Docker is not removed after your stop and you can log, attach again. Refer to Docker documentation. 

Once started cd /fortistacks/ and simply source your RC-file than you get from https://citycontrolpanel.com/openstack#openstack_api_access (link in the parameters of the user)
Be sure to add:
```shell
export OS_FLAVOR=1C-1GB
export EXT_NET=ext-net
```
At the end of your RC-file first.

## Advanced protection
If (like me) you have a middlebox in need for decryption for advanced protection. 
Download your middlebox Certificate authority in the folder and name it: ```Fortinet_CA_SSL.cer``` 

Then run
```bash 
docker build -f middlebox.Dockerfile --force-rm -t my-fortistacks-cli .
```
Simply change the name of your docker:
```shell
docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name my-fortistacks-cli  -h my-fortistacks-cli -t my-fortistacks-cli
```

## Hackers/curious 
Check Dockerfile in this folder to see how it is done.

```shell
$ docker run -v $PWD:/fortistacks/ -v $HOME/.ssh:/home/ubuntu/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortistacks-cli
 ```

