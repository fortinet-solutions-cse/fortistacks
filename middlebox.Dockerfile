
#build cmd:
# docker build -f middlebox.Dockerfile --force-rm -t my-fortistacks-cli .
# but sure to add:  export OS_CACERT=/usr/local/share/ca-certificates/Fortinet_CA_SSL.crt
# to your openstack.rc file

FROM fortinetsolutioncse/fortistacks-cli
MAINTAINER Nicolas Thomas <nthomas@fortinet.com>
# Copy the CA of your Frotgate doing mitm in the build directory as Fortinet_CA_SSL.cer
COPY  Fortinet_CA_SSL.cer /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt
RUN sudo update-ca-certificates
USER ubuntu
CMD ["/bin/bash"]
