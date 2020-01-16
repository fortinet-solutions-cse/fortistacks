# Be sure to have login (az login) first

GROUP_NAME="my-aks-fortistacks"
#REGION="francecentral"
REGION="westeurope"
  # see https://docs.microsoft.com/en-gb/azure/aks/private-clusters
az group create --name "$GROUP_NAME"  --location "$REGION"

# To accept terms
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg --publisher fortinet
az vm image terms accept --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm --publisher fortinet

DEPLOY_NAME=$GROUP_NAME"-FGT"
az group deployment create --name $DEPLOY_NAME  -g $GROUP_NAME \
 --template-uri "https://raw.githubusercontent.com/fortinetsolutions/Azure-Templates/master/FortiGate/Others/Single-VM-2-NIC-Deployment/azuredeploy.json" \
 --parameters Az-FGT-parameters.json


# Reference :https://docs.microsoft.com/en-us/azure/aks/private-clusters
# Install the aks-preview extension
az extension add --name aks-preview

az feature register --name AKSPrivateLinkPreview --namespace Microsoft.ContainerService
# check it is
az feature list -o tsv --query "[?contains(name, 'Microsoft.ContainerService/AKSPrivateLinkPreview')].{Name:name,State:properties.state}"

#Then
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Kubernetes

# Check namespaces
for ns in Microsoft.ContainerService Microsoft.Network Microsoft.Kubernetes
do
  az provider show -n $ns -o tsv --query "{Name:namespace,State:registrationState}"
done

SNET=`az network vnet subnet list     --resource-group  $GROUP_NAME     --vnet-name FortigateProtectedVnet     --query "[1].id" --output tsv`

az aks create \
    --resource-group $GROUP_NAME \
    --name "secure-AKS" \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $SNET\
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.40.3.254 \
    --service-cidr 10.40.3.0/24 \
    --generate-ssh-keys \
    --node-count 1

# Node count if quota restrictions

