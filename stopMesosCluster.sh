#!/bin/sh

./stopZookeeperCluster.sh

docker ps -a -q --filter=name=mesos-master-* | xargs -n 1 -I {} docker rm -f --volumes {}
docker ps -a -q --filter=name=mesos-slave-* | xargs -n 1 -I {} docker rm -f --volumes {}
docker ps -a -q --filter=name=marathon | xargs -n 1 -I {} docker rm -f --volumes {}
docker ps -a -q --filter=name=spark | xargs -n 1 -I {} docker rm -f --volumes {}
docker ps -a -q --filter=name=kafka-manager | xargs -n 1 -I {} docker rm -f --volumes {}
#docker ps -a -q --filter=name=logstash | xargs -n 1 -I {} docker rm -f --volumes {}
docker ps -a -q --filter=name=spark-streaming | xargs -n 1 -I {} docker rm -f --volumes {}