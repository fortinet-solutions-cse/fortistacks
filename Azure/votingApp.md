# inspired by Azure demo app

## Benchmark
```shell script
ab -r -s 120 -c 500 -n 120000 -p vote.txt -T application/x-www-form-urlencoded -k http://10.40.0.67/ 
```

with vote.txt containing: vote=Cats