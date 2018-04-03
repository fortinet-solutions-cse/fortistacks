#Docker to develop/try Ansible module for Fortigate
#build cmd:
# docker build --force-rm -t fortistacks-cli:1.2 .
# docker build --force-rm -t fortistacks-cli .
FROM ubuntu:16.04
MAINTAINER Nicolas Thomas <thomnico@gmail.com>
#Update the Ubuntu software repository inside the dockerfile with the 'RUN' command.
# Update Ubuntu Software repository
RUN apt update && apt -y upgrade && apt -y install git python-pip wget  zile byobu bash sudo python-virtualenv wget git cloud-image-utils
RUN pip install --upgrade pip && pip install python-novaclient==9.1.1 python-openstackclient python-heatclient
RUN apt clean
CMD ["/bin/bash"]
