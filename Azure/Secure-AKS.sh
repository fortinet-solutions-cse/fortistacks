#!/bin/bash -ex
#
#    Secured AKS deployment
#    Copyright (C) 2016 Fortinet  Ltd.
#
#    Authors: Nicolas Thomss  <fortistacksfortinet.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Be sure to have login (az login) first

GROUP_NAME="fortistacks-aks"
#REGION="francecentral"
REGION="westeurope"
  # see https://docs.microsoft.com/en-gb/azure/aks/private-clusters
az group create --name "$GROUP_NAME"  --location "$REGION"
#remove ssh keys to ensure proper regeneration see https://docs.microsoft.com/bs-latn-ba/azure/aks/ssh otherwize
rm -rf ~/.kube/*
# To accept terms
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg --publisher fortinet
#az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm --publisher fortinet

az  deployment group validate  --template-file FGT-FWB-VMs-2-Subnets/azuredeploy.json \
                               --resource-group $GROUP_NAME  --parameters Az-FGT-parameters.json

DEPLOY_NAME=$GROUP_NAME"-TRANSIT"
az  deployment group create --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-file FGT-FWB-VMs-2-Subnets/azuredeploy.json \
 --parameters Az-FGT-parameters.json


SNET2=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name fortistacks-Vnet     --query "[1].id" --output tsv`

## service VM on the transit network for accessing AKS
#az vm create \
#  --resource-group "$GROUP_NAME" --location "$REGION"\
#  --name fortistacks-jumphost \
#  --image UbuntuLTS \
#  --admin-username azureuser \
#  --admin-password Fortin3t-aks \
#  --subnet $SNET2  --authentication-type password  --no-wait



# Ref https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/use-network-policies.md
# Create a service principal and read in the application ID
# to find a previously created one :
# az ad sp list --show-mine --query "[?displayName=='ForSecureAKS'].{id:appId}" -o tsv
# is the id with the same name
CHECKSP=`az ad sp list --show-mine -o tsv --query "[?displayName == 'ForSecureAKS.io'].appId"`
[ -z $CHECKSP ] ||  az ad sp delete  --id $CHECKSP

SP=$(az ad sp create-for-rbac --output json  --name ForSecureAKS.io)
SP_ID=$(echo $SP | jq -r .appId)
SP_PASSWORD=$(echo $SP | jq -r .password)


## must create VNET subnet for AKS and peering with Transit (cli)
az network vnet create  --name fortistacks-aks  --resource-group $GROUP_NAME  \
  --subnet-name fortistacks-aks-sub --address-prefix 10.40.0.0/16 --subnet-prefix 10.40.0.0/16

az network route-table create --resource-group $GROUP_NAME --name fortistacks-routesForPeering
az network route-table route create --name internet --resource-group $GROUP_NAME \
     --route-table-name fortistacks-routesForPeering --next-hop-type VirtualAppliance \
     --next-hop-ip-address 172.27.40.126 --address-prefix 0.0.0.0/0

az network route-table route create --name eastwest --resource-group $GROUP_NAME \
     --route-table-name fortistacks-routesForPeering --next-hop-type VirtualAppliance \
     --next-hop-ip-address 172.27.40.126 --address-prefix 10.40.0.0/16

az network vnet subnet update --vnet-name fortistacks-aks  --resource-group $GROUP_NAME  \
   --route-table fortistacks-routesForPeering --name fortistacks-aks-sub

az network vnet peering create -g  $GROUP_NAME  -n TransitToAKS --vnet-name fortistacks-Vnet \
    --remote-vnet fortistacks-aks --allow-vnet-access --allow-forwarded-traffic
az network vnet peering create -g  $GROUP_NAME  -n AKStoTransit --vnet-name fortistacks-aks \
    --remote-vnet  fortistacks-Vnet --allow-vnet-access --allow-forwarded-traffic



# Wait 15 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate..."
sleep 25

# Get the virtual network resource ID
VNET_ID=$(az network vnet show --resource-group $GROUP_NAME --name  fortistacks-aks --query id -o tsv)

# Assign the service principal Contributor permissions to the virtual network resource
az role assignment create --assignee $SP_ID --scope $VNET_ID --role Contributor

AKSSUBNET=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name fortistacks-aks     --query "[0].id" --output tsv`

# Install the aks-preview extension
az extension add --name aks-preview

# set this to the name of your Azure Container Registry.  It must be globally unique
MYACR=fortistacksContainerRegistry

# Run the following line to create an Azure Container Registry if you do not already have one
az acr create -n $MYACR -g $GROUP_NAME --sku basic


az aks create \
    --resource-group "$GROUP_NAME" \
    --name "secure-AKS" \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $AKSSUBNET\
    --service-cidr 10.8.0.0/16 \
    --dns-service-ip 10.8.0.53 \
    --docker-bridge-address 172.17.0.1/16 \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --network-policy calico \
    --node-count 2 \
    --node-vm-size Standard_A2_v2\
    --enable-cluster-autoscaler \
    --min-count 2 --max-count 5 \
    --attach-acr $MYACR \
    --generate-ssh-keys --outbound-type userDefinedRouting
#   --enable-pod-security-policy
#    --dns-name-prefix fortistacks

# https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype
# check addons: https://github.com/Azure/aks-engine/blob/master/docs/topics/clusterdefinitions.md#addons (like tiller/helm)
# next private registry https://docs.microsoft.com/en-us/azure/aks/cluster-container-registry-integration

# add the private dns to the transit network for kubectl to work on jumphost
AKS_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv)
AKS_PRIV_DNS=$(az network private-dns  zone list -g $AKS_RESOURCE_GROUP -o tsv --query [0].name)
FTNT_VNET_ID=$(az network vnet show --resource-group $GROUP_NAME --name fortistacks-vnet --query "id" -o tsv )
az network private-dns  link vnet create --name aks-dns --virtual-network "$FTNT_VNET_ID" --zone-name "$AKS_PRIV_DNS" \
   --registration-enabled false -g "$AKS_RESOURCE_GROUP"

# Node count if quota restrictions
az aks get-credentials --resource-group "$GROUP_NAME"  --name "secure-AKS"

FGTAZIP=`az network public-ip show --name fgtaz   --resource-group $GROUP_NAME  --query ipAddress -o tsv`
echo " You can login on fortigate at https://$FGTAZIP"
echo "can configure your azure sdn connector with: "
echo "$SP"
## KAPI_ID=`az network private-endpoint show --name kube-apiserver --resource-group $AKS_RESOURCE_GROUP --query "networkInterfaces[0].id" -o tsv`
## KAPI_IP=`az network  nic show --ids $KAPI_ID --query "ipConfigurations[0].privateIpAddress" -o tsv`

