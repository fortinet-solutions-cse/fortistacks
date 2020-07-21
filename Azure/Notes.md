# Cheat sheet

## Azure CLI
```shell script
 az configure --defaults location=westeurope group=nthomas-aks-fortistacks
```
Set defaults

## kubectl
Cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/ 
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

AKS dashboard (ref https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard):
Dashboard is very limited by default (good)
```shell script
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl describe services kubernetes-dashboard --namespace=kube-system
```
Dashboard should be avoided in production. Use https://octant.dev/ which provides a better alternative (more interactive and CRD)

Check endpoint (if enabling url filter it will be blocked)



Ref https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
```shell script
CLUSTER_RESOURCE_GROUP=$(az aks show --resource-group $GROUP_NAME --name secure-aks --query nodeResourceGroup -o tsv) 
SCALE_SET_NAME=$(az vmss list --resource-group $CLUSTER_RESOURCE_GROUP --query [0].name -o tsv)
az vmss extension set  \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --vmss-name $SCALE_SET_NAME \
    --version 2.0 --publisher Microsoft.Azure.Extensions \
    --name CustomScript \
    --protected-settings '{"commandToExecute": "echo \"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQ1akNDQXM2Z0F3SUJBZ0lJS3FIV3RFSHUzM0l3RFFZSktvWklodmNOQVFFTEJRQXdnYWt4Q3pBSkJnTlYKQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJJd0VBWURWUVFIREFsVGRXNXVlWFpoYkdVeApFVEFQQmdOVkJBb01DRVp2Y25ScGJtVjBNUjR3SEFZRFZRUUxEQlZEWlhKMGFXWnBZMkYwWlNCQmRYUm9iM0pwCmRIa3hHVEFYQmdOVkJBTU1FRVpIVkVGYVVrODJUVk5CUVRoVE0wRXhJekFoQmdrcWhraUc5dzBCQ1FFV0ZITjEKY0hCdmNuUkFabTl5ZEdsdVpYUXVZMjl0TUI0WERUSXdNRFF3TVRFd01qY3lORm9YRFRNd01EUXdNakV3TWpjeQpORm93Z2FreEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJJd0VBWURWUVFICkRBbFRkVzV1ZVhaaGJHVXhFVEFQQmdOVkJBb01DRVp2Y25ScGJtVjBNUjR3SEFZRFZRUUxEQlZEWlhKMGFXWnAKWTJGMFpTQkJkWFJvYjNKcGRIa3hHVEFYQmdOVkJBTU1FRVpIVkVGYVVrODJUVk5CUVRoVE0wRXhJekFoQmdrcQpoa2lHOXcwQkNRRVdGSE4xY0hCdmNuUkFabTl5ZEdsdVpYUXVZMjl0TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGCkFBT0NBUThBTUlJQkNnS0NBUUVBOERFUk1vcGJ5aUJCVmh0WHRLM1lzVDNTS252bGJzQVNESFhiTElvSVBsTGMKR0tkTW4rditvUmlFMGU1QS9RdzlhNlloLzNvWEtlWjdML0JhbU1qU3ZpcFFNSnQwYUtERXpCYWxpYjkzKzYvMQorYmM1N3FaVGdTcFFPSDVJbElqSy9tQzNUNkVlQ2RmcGt0TlZNMXptMFE1TVZPaHovSUlGcitFUXZpWUdnMjJWClZYbTRYWDRkNjdOY0hScGFSMjIvL2RwRy9XQ0RqN013ekt3VDBHdzhhOTRRbWZ0N0hncUgwTmJEd0JHZ1pUc3gKVEhCanF5QVkvUjZja2hjaXdIMzRjUlNmNHRhWnV5MkFpaFZlbnBBNXVEemZsOExXV0RLTytnM2JUZ2xPS2d3WQpndjBRQXZVUWJseDJYT011Z1kzM2x1UVNBeFl2Uk5FVlZQa0t4VkZHS1FJREFRQUJveEF3RGpBTUJnTlZIUk1FCkJUQURBUUgvTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCQVFBeG9HQUJwSWJJemdBR2Vua2dLYXZTVUJ4eE9iZ0QKZ0xWMjlKdlpFcHp3L2xNWEJTMGhiU1dBbHZHV0VmR0pMTHk2V1h0V0tRK0ZNQ2VFS1JkblpkQmh4OHNoR3lQQgplQUpKbGVkeWNjRThHd2srejlBVGw2WlYyTlZ3cUJPUVM5aGNheDJUUE9rbXNVNFdsMmJpYmlibUxSZFA1Z0h5Ck50N3RKQU5mZHIyYnNXVWlGQ090RzJ1TS9vM3ZYT2ZSQlBSZ1RkbXMzV3N3ZG41WU1sNXk4ZXRUOWVVL1h5Q1EKTk1GRDRBV0M5cXI2WlVsWnZrSEdCKzlYejFHL2pvMUJhaEV0dUp6MGlyWG5YOHYwSDc2OW9Hd2NhSEtDUUJXWApOcEpZMEtzNGdNdVIrRDA3U3RFNFNKTnUrS2wzdnptSXBPajhMSnhEdkZ0a3NzNHFHKzlKSVJmTwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==\"| base64 -d > /usr/local/share/ca-certificates/Fortinet_CA_SSL.crt ; update-ca-certificates"}'

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
```
The long base64 is a base64 -w0 string of the FortigateCA

Connect with ssh https://docs.microsoft.com/en-us/azure/aks/ssh (for debug)
# SSH access to nodes for debug

```shell script
az vmss extension set  \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --vmss-name $SCALE_SET_NAME \
    --name VMAccessForLinux \
    --publisher Microsoft.OSTCExtensions \
    --version 1.4 \
    --protected-settings "{\"username\":\"azureuser\", \"ssh_key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"

az vmss update-instances --instance-ids '*' \
    --resource-group $CLUSTER_RESOURCE_GROUP \
    --name $SCALE_SET_NAME
```

Example app: https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough


# References
- https://github.com/microsoft/Networking-with-Kubernetes-Azure
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
```shell script
    az vmss extension set --vmss-name my-vmss --name customScript --resource-group my-group \
    --version 2.0 --publisher Microsoft.Azure.Extensions \
    --provision-after-extensions NetworkWatcherAgentLinux VMAccessForLinux  \
    --settings '{"commandToExecute": "echo testing"}'
```
See: https://docs.microsoft.com/en-us/cli/azure/vmss/extension?view=azure-cli-latest#code-try-5

Multi nodes pool: https://docs.microsoft.com/en-us/azure/aks/use-multiple-node-pools
Can be used to showcase SSL protection on/off

## does not work on AKS
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
    - mountPath: /etc/ssl/certs/ca-certificates.crt
      name: ca
      subPath: ca-certificates.crt
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

# create service account and get TOKEN
```shell script
kubectl -n kube-system create serviceaccount fortigate
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:fortigate
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='fortigate')].data.token}" -n kube-system | base64 -d)
```


# If default has all the API access
```shell script
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
```
SRC:https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm 

--network-plugin azure --network-policy Calico


https://docs.microsoft.com/en-us/azure/aks/use-network-policies

##internal load balancer   
https://docs.microsoft.com/en-us/azure/aks/internal-lb 
```yaml
metadata:
  name: azure-vote-front
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
```
Can benefit from Kustomize here

## specify egress
TODO check: 
https://docs.microsoft.com/en-us/azure/aks/egress-outboundtype
Show that we can better automate than Azure here !!


## Using ansible for demo (complex setup)
````shell script
ansible-playbook -i hosts fgt-playbook.yaml 
````
Change the IP in hosts to reflect your fortigate

# SSL CA ingest for Containers
Easiest is to put in the image for the ones who are allowed.
May want to make this an infra parameter and keep image generic
## use Azurefile (inject CA)
Hard and not really efficient see [ConfigureK8Sstorage.sh](ConfigureK8Sstorage.sh)
https://stackoverflow.com/questions/39436845/multiple-command-in-poststart-hook-of-a-container
Might be useable to inject CA on Docker instances
TODO check this https://medium.com/@paraspatidar/add-self-signed-or-ca-root-certificate-in-kubernetes-pod-ca-root-certificate-store-cb7863cb3f87#b760 
for pods CA injections

## ACR usage (Azure registry)
```shell script
az acr login --name fortistacksContainerRegistry --expose-token
```
Get the token to register your docker cmd, (access from public by default)

#TODO check if this give good feedback in our case
https://github.com/darkbitio/mkit/blob/master/README.md

Uploadfile demo https://hub.docker.com/r/mayth/simple-upload-server/ how to antivir scan files ?

## watch with crd in color
```
watch -c "kubectl get pods,lb-fgt,svc -o wide|ccze -A"
```