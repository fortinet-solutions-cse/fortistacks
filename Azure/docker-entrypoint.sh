#!/bin/bash
# entrypoint runs at every start, allow to ingest CA as a Docker ENV variable or not (generic images)
# ingest the trusted CA certificate from FGTCA environment variable which must be base64 version of the file 'base64 -w0'
[ "$FGTCA" == "none" ] || (echo "$FGTCA"| base64 -d | sudo tee  /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt > /dev/null)
# do a forced refresh of all CA to help in case of mounting the local share from volume
sudo update-ca-certificates --fresh
# force PIP to use the system wide trusted CA
[ "$FGTCA" == "none" ] || (echo "export PIP_CERT=/etc/ssl/certs/" | sudo tee  /etc/profile > /dev/null)
exec $@