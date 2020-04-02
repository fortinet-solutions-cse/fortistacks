#!/bin/bash

[ "$FGTCA" == "none" ] || (echo "$FGTCA"| base64 -d | sudo tee  /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt > /dev/null; sudo update-ca-certificates)

exec $@