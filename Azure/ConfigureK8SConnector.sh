#!/bin/bash -e
#
#    Configure Fortigate Kubernetes connector
#
#    Authors: Nicolas Thomss  <fortistacksfortinet.com>
#
# Be sure to have login (az login) first

[ -f $1 ]
export FGTCA=$(base64 Fortinet_AKS_CA.cer -w0) # or -b0 on MacOS
GROUP_NAME="fortistacks-aks"
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv)
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)

az vmss extension set      --resource-group $CLUSTER_RESOURCE_GROUP     --vmss-name $SCALE_SET_NAME   \
    --version 2.0 --publisher Microsoft.Azure.Extensions     --name CustomScript    \
    --protected-settings "{\"commandToExecute\": \"echo $FGTCA| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates --fresh\"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
echo "collecting information on Azure"
GROUP_NAME="fortistacks-aks"
AKS_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv)
KAPI_ID=`az network private-endpoint show --name kube-apiserver --resource-group $AKS_RESOURCE_GROUP --query "networkInterfaces[0].id" -o tsv`
KAPI_IP=`az network  nic show --ids $KAPI_ID --query "ipConfigurations[0].privateIpAddress" -o tsv`

kubectl -n kube-system create serviceaccount fortigate || true
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=view --serviceaccount=kube-system:fortigate || true
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='fortigate')].data.token}" -n kube-system | base64 -d)

FGTAZIP=`az network public-ip show --name fgtaz   --resource-group $GROUP_NAME  --query ipAddress -o tsv`

echo "configure your Kubernetes SDN connector with the following cli on https://$FGTAZIP"
cat <<EOF
config system sdn-connector
    edit "AKS"
        set type kubernetes
        set server $KAPI_IP
        set server-port 443
        set secret-token $TOKEN
        set update-interval 30
    next
end

EOF