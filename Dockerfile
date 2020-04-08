#Docker to develop/try Ansible module for Fortigate
#build cmd:
# docker build --force-rm -t fortinetsolutioncse/fortistacks-cli:2.0 .
# For "official build" need acces to the docker registry.
# docker build --force-rm -t fortistacks-cli .
#
FROM ubuntu:18.04
LABEL maintainer="Nicolas Thomas <nthomas@fortinet.com>"
#Update the Ubuntu software repository inside the dockerfile with the 'RUN' command.
RUN apt-get update && apt-get -y upgrade
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install git python-pip wget zile byobu bash sudo python-virtualenv wget git cloud-image-utils \
           python-openstackclient sudo python-heatclient software-properties-common apt-transport-https \
           bash-completion software-properties-common vim bash-completion
RUN apt-get clean

RUN groupadd -r ubuntu && useradd  -g ubuntu -G adm,sudo ubuntu -m -p fortinet -s /bin/bash && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-nopasswd && chmod 640 /etc/sudoers.d/99-nopasswd
# if FGTCA is set
# must create a base64 env with the CA in it: FGTCA=$(base64 Fortinet_CA_SSL.crt -w0)
# and run with -e FGTCA
ENV FGTCA none
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh"]
USER ubuntu
CMD [ "/bin/bash"]
