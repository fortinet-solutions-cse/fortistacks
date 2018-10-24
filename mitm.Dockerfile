
#build cmd:
# docker build -f mitm.Dockerfile --force-rm -t my-fortistacks-cli .

FROM fortinetsolutioncse/fortistacks-cli
MAINTAINER Nicolas Thomas <nthomas@fortinet.com>
# Copy the CA of your Frotgate doing mitm in the build directory as Fortinet_CA_SSL.cer
COPY  Fortinet_CA_SSL.cer /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt
RUN sudo update-ca-certificates
USER ubuntu
CMD ["/bin/bash"]
