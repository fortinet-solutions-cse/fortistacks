
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