#!/bin/bash -e
#
#    Configure Fortigate Kubernetes connector
#
#    Authors: Nicolas Thomss  <fortistacksfortinet.com>
#
# Be sure to have login (az login) first

# src: https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/azure-files-volume.md
# create a share Azurefile (cheaper ?) to try to share CA certificates to pods.

AKS_PERS_STORAGE_ACCOUNT_NAME=fortistacksstorage
AKS_PERS_RESOURCE_GROUP=fortistacks-aks
AKS_PERS_LOCATION=westeurope
AKS_PERS_SHARE_NAME=aksshares


# Create a storage account
az storage account create -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $AKS_PERS_RESOURCE_GROUP -l $AKS_PERS_LOCATION --sku Standard_LRS

# Export the connection string as an environment variable, this is used when creating the Azure file share
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n $AKS_PERS_STORAGE_ACCOUNT_NAME -g $AKS_PERS_RESOURCE_GROUP -o tsv)

# Create the file share
az storage share create -n $AKS_PERS_SHARE_NAME --connection-string $AZURE_STORAGE_CONNECTION_STRING

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $AKS_PERS_RESOURCE_GROUP --account-name $AKS_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv)

# Echo storage account name and key
echo Storage account name: $AKS_PERS_STORAGE_ACCOUNT_NAME
echo Storage account key: $STORAGE_KEY

kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$AKS_PERS_STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY
