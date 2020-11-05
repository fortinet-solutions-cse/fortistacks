# Notes about docker/Helm K8S on testing FWEB in K8S

## Image
```shell script
docker login fortistackscontainerregistry.azurecr.io -u 00000000-0000-0000-0000-000000000000 -p eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjZLQUM6RUVIUDpUVlpGOk5CNEg6VjdCRzoyQlc0OkxWQk46MlhJWjpWVzNWOlA0RTI6N09GMzpFQlpMIn0.eyJqdGkiOiJmYzkzMWE3YS05MjNhLTQxNzctYjBmOS1jOWY2M2ZkNjg3ZTciLCJzdWIiOiJudGhvbWFzQGF6dXJlc3RvcmVmb3J0aW5ldC5vbm1pY3Jvc29mdC5jb20iLCJuYmYiOjE2MDQ1NjM1MDQsImV4cCI6MTYwNDU3NTIwNCwiaWF0IjoxNjA0NTYzNTA0LCJpc3MiOiJBenVyZSBDb250YWluZXIgUmVnaXN0cnkiLCJhdWQiOiJmb3J0aXN0YWNrc2NvbnRhaW5lcnJlZ2lzdHJ5LmF6dXJlY3IuaW8iLCJ2ZXJzaW9uIjoiMS4wIiwiZ3JhbnRfdHlwZSI6InJlZnJlc2hfdG9rZW4iLCJ0ZW5hbnQiOiI5NDJiODBjZC0xYjE0LTQyYTEtOGRjZi00YjIxZGVjZTYxYmEiLCJwZXJtaXNzaW9ucyI6eyJhY3Rpb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJub3RBY3Rpb25zIjpudWxsfSwicm9sZXMiOltdfQ.k6w1f4VhjBmgKbA-Wb6gJ_b3Xu5rGTV3VMeEwgWFE19G1Ey_-5LbOueY4pDihZ-D0B4rIET-Fen_iJREVQ8-tZLZSLqSLWEUDW6PLwP6jps4z4XfX4kM7GX_oZvGTkZPnQpr580Z5MhlRV3N5ObmrOm1m7rTnEo_6qO4f_kEVBD1NuPCDdUrFaf_AWaUvLVkcG6mrLRXnxvCgvINieTC1P9CPMn6QdsmfkzOGTFP_P_HvB4gJi7xmHNwes-AkVJb4D7p1vzgvhLWWzSuRxW_sKmu8hjX9-jaMPcvLidyOwh2lfnC__UFX02_cFCquSuFY4AkWys3Uk8-JNeUZyMGKg
unzip ~/Downloads/FWB_DOCKER-v600-build1102-FORTINET.out.docker.zip 
cd image-docker-64/
docker build -t fortistackscontainerregistry.azurecr.io/fortiweb:6.3.7 .
docker push fortistackscontainerregistry.azurecr.io/fortiweb:6.3.7 
```


Create the secret with the license file in it:
```shell script
kubectl create secret generic fwblicense --from-file=./vm.lic 
```
Must be named vm.lic

Use fwb-single-d0.yml for a full day0+license example
##Storage 
```yaml
        volumeMounts:
          - mountPath: "/var/my-app/id_rsa"
              subPath: id_rsa
            name: ssh-key
            readOnly: true
      volumes:
        - name: ssh-key
          secret:
            secretName: ssh-key
            items:
              - key: id_rsa
                path: id_rsa
```