If not using an Ubuntu machine:

But won't be able to have your own OpenStack then.


#need to do a Dockerfile (fortistacks cli)
Check dockerfile
```shell
$ docker run -v $HOME/src/fortistacks/:/fortistacks/ -v $HOME/.ssh:/root/.ssh/ --rm -i  --name fortistacks-cli  -h fortistacks-cli -t fortistacks-cli:1.2 
 ```

Ensure to have the citycloud rc environment variable in the file