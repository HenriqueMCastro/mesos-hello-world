#!/bin/bash

zookeeperServers="zookeeper-node-1,zookeeper-node-2,zookeeper-node-3"
for id in `seq 1 3`;
do
    #docker run -d  --net=mynetwork -h zookeeper-node-${id} --name=zookeeper-node-${id} netflixoss/exhibitor:1.5.2
    #http://zookeeper-node-${id}:8080/exhibitor/v1/ui/index.html
    docker run -d  --net=mynetwork -h zookeeper-node-${id} -e ZOO_LOG_DIR=/var/log/zookeeper -e MYID=${id} -e SERVERS=${zookeeperServers} --name=zookeeper-node-${id} mesoscloud/zookeeper:3.4.6-ubuntu-14.04
done
