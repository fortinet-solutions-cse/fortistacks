#!/bin/bash -ex
#
#    Secured AKS deployment
#    Copyright (C) 2016 Fortinet  Ltd.
#
#    Authors: Nicolas Thomss  <nthomasfortinet.com>
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

GROUP_NAME="nthomas-aks-fortistacks"
#REGION="francecentral"
REGION="westeurope"
  # see https://docs.microsoft.com/en-gb/azure/aks/private-clusters
az group create --name "$GROUP_NAME"  --location "$REGION"
#remove ssh keys to ensure proper regeneration see https://docs.microsoft.com/bs-latn-ba/azure/aks/ssh otherwize
rm -f ~/.ssh/id* ~/.kube/*
# To accept terms
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg --publisher fortinet
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm --publisher fortinet

az group deployment validate  --template-file FGT-FWB-VMs-2-Subnets/azuredeploy.json \
                               --resource-group $GROUP_NAME  --parameters Az-FGT-parameters.json

DEPLOY_NAME=$GROUP_NAME"-TRANSIT"
az group deployment create --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-file FGT-FWB-VMs-2-Subnets/azuredeploy.json \
 --parameters Az-FGT-parameters.json


SNET2=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name nthomas-Vnet     --query "[1].id" --output tsv`

# service VM on the transit network for accessing AKS
az vm create \
  --resource-group "$GROUP_NAME" \
  --name nthomas-jumphost \
  --image UbuntuLTS \
  --admin-username azureuser \
  --admin-password Fortin3t-aks \
  --subnet $SNET2  --authentication-type password



# Ref https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/use-network-policies.md
# Create a service principal and read in the application ID
# to find a previously created one :
# az ad sp list --show-mine --query "[?displayName=='ForSecureAKS'].{id:appId}" -o tsv
# is the id with the same name
CHECKSP=`az ad sp list --show-mine -o tsv --query "[?displayName == 'ForSecureAKS'].appId"`
[ -z $CHECKSP ] ||  az ad sp delete  --id $CHECKSP

SP=$(az ad sp create-for-rbac --output json  --name ForSecureAKS)
SP_ID=$(echo $SP | jq -r .appId)
SP_PASSWORD=$(echo $SP | jq -r .password)


## must create VNET subnet for AKS and peering with Transit (cli)
az network vnet create  --name fortistacks-aks  --resource-group $GROUP_NAME  \
  --subnet-name fortistacks-aks-sub --address-prefix 10.40.0.0/16 --subnet-prefix 10.40.0.0/16

az network route-table create --resource-group $GROUP_NAME --name nthomas-routesForPeering
az network route-table route create --name default --resource-group $GROUP_NAME \
     --route-table-name nthomas-routesForPeering --next-hop-type VirtualAppliance \
     --next-hop-ip-address 172.27.40.126 --address-prefix 0.0.0.0/0

az network route-table route create --name default --resource-group $GROUP_NAME \
     --route-table-name nthomas-routesForPeering --next-hop-type VnetLocal --address-prefix 10.40.0.0/16

az network vnet subnet update --vnet-name fortistacks-aks  --resource-group $GROUP_NAME  \
   --route-table nthomas-routesForPeering --name fortistacks-aks-sub

az network vnet peering create -g  $GROUP_NAME  -n TransitToAKS --vnet-name nthomas-Vnet \
    --remote-vnet fortistacks-aks --allow-vnet-access --allow-forwarded-traffic
az network vnet peering create -g  $GROUP_NAME  -n AKStoTransit --vnet-name fortistacks-aks \
    --remote-vnet  nthomas-Vnet --allow-vnet-access --allow-forwarded-traffic



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


az aks create \
    --resource-group "$GROUP_NAME" \
    --name "secure-AKS" \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $AKSSUBNET\
    --generate-ssh-keys \
    --node-count 2 \
    --service-cidr 10.8.0.0/16 \
    --dns-service-ip 10.8.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --network-policy calico
# Node count if quota restrictions
az aks get-credentials --resource-group "$GROUP_NAME"  --name "secure-AKS"

