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

# To accept terms
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg --publisher fortinet
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm --publisher fortinet

DEPLOY_NAME=$GROUP_NAME"-FGT"
az group deployment create --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-file Single-VM-2-NIC-Deployment/azuredeploy.json \
 --parameters Az-FGT-parameters.json

# Ref https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/use-network-policies.md
# Create a service principal and read in the application ID
SP=$(az ad sp create-for-rbac --output json)
SP_ID=$(echo $SP | jq -r .appId)
SP_PASSWORD=$(echo $SP | jq -r .password)

# Wait 15 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate..."
sleep 15

# Get the virtual network resource ID
VNET_ID=$(az network vnet show --resource-group $GROUP_NAME --name nthomas-Vnet --query id -o tsv)

# Assign the service principal Contributor permissions to the virtual network resource
az role assignment create --assignee $SP_ID --scope $VNET_ID --role Contributor


SNET2=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name nthomas-Vnet     --query "[1].id" --output tsv`

# Install the aks-preview extension
az extension add --name aks-preview
#remove ssh keys to ensure proper regeneration see https://docs.microsoft.com/bs-latn-ba/azure/aks/ssh otherwize
rm -f ~/.ssh/id*

az aks create \
    --resource-group "$GROUP_NAME" \
    --name "secure-AKS" \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $SNET2\
    --generate-ssh-keys \
    --node-count 2 \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --service-principal $SP_ID \
    --client-secret $SP_PASSWORD \
    --network-policy calico
# Node count if quota restrictions
az aks get-credentials --resource-group "$GROUP_NAME"  --name "secure-AKS"

az vm create \
  --resource-group "$GROUP_NAME" \
  --name nthomas-jumphost \
  --image UbuntuLTS \
  --admin-username azureuser \
  --admin-password Fortin3t-aks \
  --subnet $SNET2  --authentication-type password





