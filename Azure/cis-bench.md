# Run cis bench

On every node:
```shell script






curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
for bench in dil docker kubernetes 
do 
 inspec exec https://github.com/dev-sec/cis-${bench}-benchmark.git --chef-license=accept-silent  --reporter json:output/${bench}-`uname -n`.json
done
```

Collect output json files.
Then:
# visual
https://github.com/presidenten/dev-sec-cis-benchmarks


All in one from vmware https://sonobuoy.io/