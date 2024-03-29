#!/bin/sh

#cqlsh -e "SOURCE 'schema.cql'"
#cqlsh -e "copy iot.buildinginfo from 'buildinginfo.csv' with header=true"
#cqlsh -e "copy iot.deviceinfo from 'deviceinfo.csv' with header=true"
#create a cluster
gcloud config set compute/zone us-west1-b
gcloud container clusters create dcproject


##clone all the required repositories
git clone https://github.com/shsh9888/kafka-on-kubernetes
git clone https://github.com/shsh9888/cassandra-on-kubernetes.git
git clone https://github.com/shsh9888/flink
git clone https://github.com/shsh9888/Cassandra-Avro-Kafka-Python
git clone https://github.com/shsh9888/Flask-App
git clone https://github.com/kamalchaturvedi/aggregationcronjobs.git



mkdir -p build
cp kafka-on-kubernetes/*.yaml ./build/
cp cassandra-on-kubernetes/*.yaml ./build/

##running Kafka and Cassandra
cd build && kubectl create -f .
``
cd .. && cd flink/flink-container/kubernetes/

##running the flink job
kubectl create -f job-cluster-service.yaml
FLINK_IMAGE_NAME=gcr.io/lab7-258103/fuck:1.0 FLINK_JOB_PARALLELISM=1 envsubst < job-cluster-job.yaml.template | kubectl create -f -
FLINK_IMAGE_NAME=gcr.io/lab7-258103/fuck:1.0 FLINK_JOB_PARALLELISM=1 envsubst < task-manager-deployment.yaml.template | kubectl create -f -


cd ../../../

echo "Waiting for Cassandra, Wating for 4 minutes.If you see an error here you might have to increase sleep"
sleep 4m


###Adding data to Cassandra
find_cassandra_pods="kubectl get pods -l name=cassandra"

first_running_seed=$($find_cassandra_pods --no-headers | \
    grep Running | \
    grep 1/1 | \
    head -1 | \
    awk '{print $1}')

echo "Pod found for Cassandra : $first_running_seed"

kubectl cp schema.cql $first_running_seed:/home/
kubectl cp deviceinfo.csv $first_running_seed:/home/
kubectl cp buildinginfo.csv $first_running_seed:/home/


kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"SOURCE '/home/schema.cql'"\"
kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"copy iot.buildinginfo from '/home/buildinginfo.csv' with header=true\""
kubectl exec -it $first_running_seed -- bash -c "cqlsh -e \"copy iot.deviceinfo from '/home/deviceinfo.csv' with header=true\""


##running the simulator: data producer  
cd Cassandra-Avro-Kafka-Python && kubectl create -f final-simulator.yaml


## aggregation jobs spark
cd ..
cd aggregationcronjobs

kubectl create -f perminutejob.yaml
kubectl create -f perhourjob.yaml
kubectl create -f perdayjob.yaml

cd ..
##deploying the rest endpoint
cd Flask-App
sh deploy.sh

echo "Done!!!!!!"

