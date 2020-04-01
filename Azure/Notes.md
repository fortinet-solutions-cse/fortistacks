# Cheat sheet

## Azure CLI
```shell script
 az configure --defaults location=westeurope group=nthomas-aks-fortistacks
```
Set defaults

## kubectl
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
Example: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

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

# SSL inspection
TODO: check if option in az aks or kubectl.
Nodes: 
 Might be able in deamonset to mount /etc/ and push a docker image to update the CA cert (more generic)
https://github.com/Azure/custom-script-extension-linux
```bash 
    az vmss extension set --vmss-name my-vmss --name customScript --resource-group my-group \
    --version 2.0 --publisher Microsoft.Azure.Extensions \
    --provision-after-extensions NetworkWatcherAgentLinux VMAccessForLinux  \
    --settings '{"commandToExecute": "echo testing"}'
```
See: https://docs.microsoft.com/en-us/cli/azure/vmss/extension?view=azure-cli-latest#code-try-5

Multi nodes pool: https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools
Can be used to showcase SSL protection on/off

Pods: PodPreset 
https://stackoverflow.com/questions/57090050/is-it-possible-to-use-podpresets-in-openshift-3-11-3-7
````yaml
kind: PodPreset
apiVersion: settings.k8s.io/v1alpha1
metadata:
  name: inject-certs
spec:
  selector: {}
  volumeMounts:
    - mountPath: /etc/ssl/certs/cert1.pem
      name: ca
      subPath: cert1.pem
  volumes:
    - configMap:
        defaultMode: 420
        name: ca-pemstore
      name: ca
````
Then postStart to run update-ca-certificate https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/#define-poststart-and-prestop-handlers
# Token
https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/
###How to get token for K8S connector: 

TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
TODO fix this can be:https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm 


--network-plugin azure --network-policy Calico


https://docs.microsoft.com/en-us/azure/aks/use-network-policies

## fix/bug ?
src: https://github.com/Azure/AKS/issues/400
az network vnet subnet update -n ${azurerm_subnet.aks_subnet.name} -g ${azurerm_resource_group.aks_resource_group.name} --vnet-name ${azurerm_virtual_network.aks_virtualnetwork.name} --route-table $(az resource list --resource-group MC_${azurerm_resource_group.aks_resource_group.name}_${azurerm_kubernetes_cluster.aks_cluster.name}_<YOUR LOCATION HERE> --resource-type Microsoft.Network/routeTables --query '[].{ID:id}' -o tsv)"
