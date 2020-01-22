# Dockerfile for azure cli when using SSL inspection.
# build cmd:
# docker build --force-rm -t myaz-cli .

FROM mcr.microsoft.com/azure-cli
MAINTAINER Nicolas Thomas <nthomas@fortinet.com>
RUN apk update && apk add ca-certificates gettext&& rm -rf /var/cache/apk/*
# gettext to have the envsubst cli

# Copy the CA of your Frotgate doing mitm in the build directory as Fortinet_CA_SSL.cer
COPY  ./Fortinet_CA_SSL.cer /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt
RUN update-ca-certificates
# add the cert at the end of the python chain
RUN  cat /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt >> /usr/local/lib/python3.6/site-packages/certifi/cacert.pem
RUN echo "export PIP_CERT=/etc/ssl/certs/" >> /etc/profile ;  az extension add --name virtual-wan
RUN az extension add --name aks-preview ; az aks install-cli
RUN adduser az -D -s bash;  echo ". /usr/local/bin/az.completion.sh" >> ~az/.bashrc ; echo 'export PS1="\h \$"'>> ~az/.bashrc ; chown az:az  ~az/.bashrc
#USER az
#CMD ["/bin/bash"]
