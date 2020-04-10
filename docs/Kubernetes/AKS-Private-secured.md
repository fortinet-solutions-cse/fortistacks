# Securing Azure managed Kubernetes (AKS)

This demo automate the deployment of a Fortigate a Fortiweb and an Azure managed Kubernetes (AKS) with private API feature.
The goal is to set the scene to help understand and secure with Fortinet solutions an AKS environment and applications.
It has been kept simple (1 Fortigate) for education and cost perspective. Contact a Fortinet representative for a completly scalable and automated solution.

# Bootstrap
Of course you need an Azure account with all necessary subscriptions and permissions.
Get the code
```shell script
git clone https://github.com/fortinet-solutions-cse/fortistacks.git --recursive
cd fortistacks/Azure
```
## Using provided docker image
```shell script
docker run -v $PWD:/Azure/  -i --name az-aks-cli  -h az-aks-cli -t fortinetsolutioncse/az-aks-cli
```

If like me you have internal SSL inspection you use the same image.
(Curious check the code).

```shell script
export FGTCA=$(base64 Fortinet_CA_SSL.cer -b0)
# this is for MacOS use -w0 on Linux
docker run -v $PWD:/Azure/ -e FGTCA -i --name az-aks-cli  -h az-aks-cli -t fortinetsolutioncse/az-aks-cli
```


## Script
```shell script
az login
./Secure-AKS.sh
```
The script will deploy the following and ensure all AKS traffic goes to the Firewall for analysis.
Again for education, feature it can be split and made elastic.
![Architecture](SecureAKS.svg)

# Access the environment

## VPN to Fortigate
## Verify Kubectl works
## Scale
# Debug 

# SSL inspection
## K8S Nodes (i.e. VMs)
Ref https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
You get the Fortinet_CA_SSL.crt from your running Fortigate

```shell script
export FGTCA=$(base64 Fortinet_CA_SSL.crt -w0) # or -b0 on MacOS
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv) 
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)
az vmss extension set  \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --vmss-name $SCALE_SET_NAME \
    --version 2.0 --publisher Microsoft.Azure.Extensions \
    --name CustomScript \
    --protected-settings '{"commandToExecute": "echo \"$FGTCA\"| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates"}'

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
```
This install and trust the Fortigate CA for SSL inspection, allowing antivirus and DLP on your infra and application code.

## K8S containers

