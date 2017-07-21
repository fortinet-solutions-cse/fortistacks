#!/usr/bin/env bash
## install docker
#apt install docker.io
#sudo adduser $USER docker
#reboot
# ref is https://openbaton.github.io/documentation/nfvo-installation-docker/

#Start raabitmq
docker run -d --hostname my-rabbit --name some-rabbit rabbitmq:3
docker pull openbaton/standalone
#switch to 8445 (conflict with lxd)
docker run --name openbaton -d -h openbaton-rabbitmq -p 8080:8080 -p 5672:5672 -p 15672:15672 -p 8445:8443 -e RABBITMQ_BROKERIP=10.10.10.1 openbaton/standalone
