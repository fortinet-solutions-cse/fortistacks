# inspired by Azure demo app

## Benchmark
```shell script
ab -c 20 -n 12000 -p vote.txt -T application/x-www-form-urlencoded http://10.40.0.67/
```

with vote.txt containing: vote=Cats