#!/bin/bash
# az vmss extension set --vmss-name my-vmss --name customScript --resource-group my-group \
#    --version 2.0 --publisher Microsoft.Azure.Extensions \
#    --settings '{"commandToExecute": "echo testing"}'
echo $1 | base64 -d | sudo tee /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt >/dev/null
sudo update-ca-certificates
