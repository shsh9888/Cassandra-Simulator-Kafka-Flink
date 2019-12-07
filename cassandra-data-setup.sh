#!/bin/sh

#cqlsh -e "SOURCE 'schema.cql'"
#cqlsh -e "copy iot.buildinginfo from 'buildinginfo.csv' with header=true"
#cqlsh -e "copy iot.deviceinfo from 'deviceinfo.csv' with header=true"


find_cassandra_pods="kubectl get pods -l name=cassandra"

first_running_seed=$($find_cassandra_pods --no-headers | \
    grep Running | \
    grep 1/1 | \
    head -1 | \
    awk '{print $1}')

kubectl cp schema.cql $first_running_seed:/home/
kubectl cp deviceinfo.csv $first_running_seed:/home/
kubectl cp buildinginfo.csv $first_running_seed:/home/



kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"SOURCE '/home/schema.cql'"\"
kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"copy iot.buildinginfo from '/home/buildinginfo.csv' with header=true\""
kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"copy iot.deviceinfo from '/home/deviceinfo.csv' with header=true\""

