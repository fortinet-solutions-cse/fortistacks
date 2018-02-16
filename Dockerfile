#Docker to develop/try Ansible module for Fortigate
#Start with ubuntu 
FROM ubuntu:16.04
MAINTAINER Nicolas Thomas <thomnico@gmail.com>
#Update the Ubuntu software repository inside the dockerfile with the 'RUN' command.
# Update Ubuntu Software repository
RUN apt update && apt -y upgrade && apt -y install git python-pip wget  zile byobu bash
RUN pip install --upgrade pip && pip install python-novaclient==9.1.1 python-openstackclient
CMD ["/bin/bash"]
