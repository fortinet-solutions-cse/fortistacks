# Dockerfile including EICAR test file to demo antivirus
#  docker build -t fortinetsolutioncse/ubuntu-eicar -f EICAR.Dockerfile .
FROM ubuntu:18.04
LABEL maintainer="Nicolas Thomas <nthomas@fortinet.com>" provider="Fortinet"
#check http://2016.eicar.org/86-0-Intended-use.html
RUN (echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /usr/local/bin/eicar)
RUN chmod 755 /usr/local/bin/eicar
CMD ["/bin/bash"]
