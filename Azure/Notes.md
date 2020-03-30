# Cheat sheet

Get kubectl https://kubernetes.io/docs/tasks/tools/install-kubectl/
```sudo snap install kubectl --classic

kubectl version
```
Completion
As root
```shell script
source <(kubectl completion bash)
kubectl completion bash >/etc/bash_completion.d/kubectl

```

Connect with ssh https://docs.microsoft.com/en-us/azure/aks/ssh


# References
- https://docs.microsoft.com/en-gb/azure/aks/private-clusters
- https://eventmarketing.blob.core.windows.net/mstechsummit2018-after/CI32_PDF_TS18.pdf
- https://medium.com/@tufin/integrating-aks-cluster-with-azure-firewall-b3e56d163866

- https://github.com/Azure/azure-cli-extensions/tree/master/src/aks-preview (especially the IP restriction to API manager)

- https://github.com/weaveworks/kured
- https://github.com/Azure/k8s-best-practices/blob/master/Security.md

## Certificats 

Extract cluster CA:
kubectl config view --minify --raw --output 'jsonpath={..cluster.certificate-authority-data}' | base64 -d | openssl x509 -text -out -

# Networking
https://github.com/microsoft/Networking-with-Kubernetes-Azure
Internal LB: https://docs.microsoft.com/en-us/azure/aks/internal-lb

# Token
https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/
###How to get token for K8S connector: 

TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)


--network-plugin azure --network-policy Calico


https://docs.microsoft.com/en-us/azure/aks/use-network-policies

## fix/bug ?
src: https://github.com/Azure/AKS/issues/400
az network vnet subnet update -n ${azurerm_subnet.aks_subnet.name} -g ${azurerm_resource_group.aks_resource_group.name} --vnet-name ${azurerm_virtual_network.aks_virtualnetwork.name} --route-table $(az resource list --resource-group MC_${azurerm_resource_group.aks_resource_group.name}_${azurerm_kubernetes_cluster.aks_cluster.name}_<YOUR LOCATION HERE> --resource-type Microsoft.Network/routeTables --query '[].{ID:id}' -o tsv)"
