# Dockerfile for azure cli, ansible and kubectl with optionnal SSL inspection.
# build cmd:
# on MacOS
# docker build --build-arg FGTCA_BUILD=$(base64 Fortinet_CA_SSL.cer -b0) --pull -t fortinetsolutioncse/az-aks-cli .
#on Linux
# docker build --build-arg FGTCA_BUILD=$(base64 Fortinet_CA_SSL.cer -w0) --pull -t az-aks-cli .

#was FROM mcr.microsoft.com/azure-cli but completion do not work well on microsoft image
FROM ubuntu:18.04
LABEL maintainer="Nicolas Thomas <nthomas@fortinet.com>" provider="Fortinet"
#Update the az software repository inside the dockerfile with the 'RUN' command.

RUN apt-get update
ARG FGTCA_BUILD
ENV DEBIAN_FRONTEND=noninteractive
ENV FGTCA none
RUN apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg python3-pip software-properties-common
#build arg to allow ssl inspect during build must create a base64 env with the CA in it: export FGTCA=$(base64 Fortinet_CA_SSL.crt -w0)
#RUN [ $FGTCA_BUILD = "none"] || (echo "${FGTCA_BUILD}"| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt; update-ca-certificates)
RUN  (echo "${FGTCA_BUILD}"| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt; update-ca-certificates)
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh"]


RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc |  apt-key add -
#| gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
RUN AZ_REPO=$(lsb_release -cs); echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" > /etc/apt/sources.list.d/azure-cli.list
RUN curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add -
RUN  curl  https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb ; dpkg -i packages-microsoft-prod.deb
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main"  > /etc/apt/sources.list.d/kubernetes.list
RUN add-apt-repository universe
RUN apt-get update && (apt-get -y install bash-completion kubectl openssh-client apache2-utils  jq azure-cli sudo  wget zile byobu ccze powershell)&& \
        kubectl completion bash >/etc/bash_completion.d/kubectl
# Must use python3 or the fortios ansible modules do not work
RUN pip3 --no-cache-dir install ansible
# see https://galaxy.ansible.com/fortinet/fortios
RUN ansible-galaxy collection install fortinet.fortios
RUN export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt ;az extension add --name aks-preview
RUN groupadd -r az && useradd  -g az -G adm,sudo az -m -p fortinet -s /bin/bash && \
    echo "az ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-nopasswd && chmod 640 /etc/sudoers.d/99-nopasswd; \
    echo "export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt " >> ~az/.bashrc ; \
    echo 'export PS1="\u@\h:\w $"'>> ~az/.bashrc ; chown az:az  ~az/.bashrc
RUN apt-get -y upgrade && apt-get clean
# remove the CA used during build and rely on ENV at runtime avoid allowing access in non wanted places
RUN rm -f /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt && update-ca-certificates
USER az
CMD ["/bin/bash"]
