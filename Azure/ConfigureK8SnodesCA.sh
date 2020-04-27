#!/bin/bash -e
#
#    Configure Fortigate Kubernetes connector
#
#    Authors: Nicolas Thomss  <fortistacksfortinet.com>
#
# Be sure to have login (az login) first
[ $# == 1 ] || echo "Must pass CA file as argument"
[ -f $1 ]  || echo "Argument $1 must be a file "
echo "collecting information on Azure"

GROUP_NAME="fortistacks-aks"
export FGTCA=$(base64 $1 -w0) # or -b0 on MacOS
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv)
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)

az vmss extension set      --resource-group $CLUSTER_RESOURCE_GROUP     --vmss-name $SCALE_SET_NAME   \
    --version 2.0 --publisher Microsoft.Azure.Extensions     --name CustomScript    \
    --protected-settings "{\"commandToExecute\": \"echo $FGTCA| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates --fresh; service docker restart \"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME