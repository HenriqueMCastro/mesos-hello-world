#!/bin/bash

#network="172.18.0.0./16"

die () {
    echo >&2 "$@"
    exit 1
}

buildImages() {
    echo "Building mesos master,slave and marathon images"
    docker build -t mesos-master master
    docker build -t mesos-slave slave
    docker build -t marathon marathon
    docker build -t kafka-manager kafka-manager
#    docker build -t logstash logstash
    docker build -t spark-streaming spark-streaming
}

startMasters() {
    echo "Starting up masters docker containers"
    zkMesos="zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/mesos"
    zkMarathon="zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/marathon"
    for masterId in `seq 1 ${numberOfMasters}`;
    do
        hostname=mesos-master-${masterId}
        docker run -d  --privileged --net=mynetwork -h ${hostname} --name=${hostname} -e ZK_MESOS=${zkMesos} -e ZK_MARATHON=${zkMarathon} -p 9001:8080 -p 5050:5050 mesos-master
    done
}

startSlaves() {
    echo "Starting up slaves docker containers"
    #zk://10.1.51.101:2181,10.1.51.102:2181,10.1.51.103:2181/mesos --zk 10.1.51.101:2181,10.1.51.102:2181,10.1.51.103:2181/kafka
    #zkMesos="zk://10.1.51.101:2181,10.1.51.102:2181,10.1.51.103:2181/mesos"
    zkMesos="zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/mesos"
    #zkKafka="10.1.51.101:2181,10.1.51.102:2181,10.1.51.103:2181/kafka"
    zkKafka="zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/kafka"
    for slaveId in `seq 1 ${numberOfSlaves}`;
        do
            hostname=mesos-slave-${slaveId}
            #docker run -d --privileged --net=mynetwork --add-host=backup.data.prs.adhslx.int:10.1.51.102 --name=${hostname} mesos_slave

            docker run -d --privileged --net=mynetwork -h ${hostname} -e ZK_MESOS=$zkMesos -e ZK_KAFKA=${zkKafka} --name=${hostname} mesos-slave
           # sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup mesos-slave --hostname=$hostname --ip=$containerIp --master=$zkMesos --log_dir=/var/log/mesos --logging_level=INFO --containerizers=docker,mesos --executor_registration_timeout=5mins > foo.out 2> foo.err < /dev/null &"
           # sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup service docker start > foo.out 2> foo.err < /dev/null &"
           # sshpass -p "root" scp -o StrictHostKeyChecking=no ../chronos/runCronJob root@"${hostname}":~
           # sshpass -p "root" scp -o StrictHostKeyChecking=no ../chronos/chronosexec root@"${hostname}":~
 	   # sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "chmod a+rwx -R /root"
	done
}

startMarathon() {
    marathonUiPort=9000;
    zkMesos="zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/mesos"
    zkMarathon="zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/marathon"
    docker run -d --privileged -h marathon --net=mynetwork -p ${marathonUiPort}:8080 -e ZK_MESOS=${zkMesos} \
    -e ZK_MARATHON=${zkMarathon} -e WEB_UI_URL=http://localhost:${marathonUiPort} --name=marathon marathon
}

startSparkHost() {
    docker run -d --privileged -h spark --net=mynetwork --name=spark sequenceiq/spark:1.6.0
}

startKafka() {
    curl -X POST -H "Content-Type: application/json" 'http://marathon:8080/v2/apps' -d '{
        "id": "kafka-cluster",
        "cmd": "cd /kafka; ./kafka-mesos.sh scheduler",
        "cpus": 1,
        "mem": 2048,
        "instances": 1,
        "ports": [0, 0],
        "constraints": [["hostname", "LIKE", "mesos-slave-1"]]
    }'
}

startMesosDns() {
     sleep 1
     curl -X POST -H "Content-Type: application/json" 'http://marathon:8080/v2/apps' -d '{
        "id": "mesos-dns",
        "cmd": "$GOPATH/src/github.com/mesosphere/mesos-dns/mesos-dns -v=1 -config=$GOPATH/src/github.com/mesosphere/mesos-dns/config.json",
        "cpus": 1,
        "mem": 2048,
        "instances": 1,
        "ports": [0, 0],
        "constraints": [["hostname", "LIKE", "mesos-slave-1"]]
    }'
}

startKafkaBrokers() {
    sleep 10
    curl "http://mesos-slave-1:7000/api/broker/add?broker=0&cpus=1&mem=1024"
    curl "http://mesos-slave-1:7000/api/broker/add?broker=1&cpus=1&mem=1024"
    curl "http://mesos-slave-1:7000/api/broker/add?broker=2&cpus=1&mem=1024"
    curl "http://mesos-slave-1:7000/api/broker/start?broker=0"
    curl "http://mesos-slave-1:7000/api/broker/start?broker=1"
    curl "http://mesos-slave-1:7000/api/broker/start?broker=2"
}

startKafkaManager() {
    zkHosts="zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181"
    docker run --privileged -d -t --net=mynetwork -h kafka-manager --name kafka-manager -p 9200:9000 -e ZK_HOSTS=${zkHosts} kafka-manager

}
#awaitMarathonStartup() {
#    ping -c 3 marathon > /dev/null 2>&1
#    if [ $? -ne 0 ]
#    then
#   # Use your favorite mailer here:
# do something
    #fi
#
#}

[ "$#" -eq 2 ] || die "2 arguments required (number of masters and number of slaves), $# provided"
numberOfMasters=${1}
numberOfSlaves=${2}

./startZookeeperCluster.sh
buildImages
#createDockerNetwork
#stopRunningContainers
#echo "Starting masters"
startMasters
startSlaves
startMarathon
startSparkHost
startKafkaManager
sleep 10
#startMesosDns
startKafka
startKafkaBrokers
#docker run --privileged -d -t --net=mynetwork -h logstash --name logstash -e LOGSTASH_CONF=/opt/logstash/config/logstash.conf logstash
docker run --privileged -d -t --net=mynetwork -h spark-streaming --name spark-streaming spark-streaming

#docker run --privileged -d -t --net=mynetwork --name kafka-manager -p 9000:9000 -e ZK_HOSTS=${ZK_HOSTS} kafka-manager

#echo "Configuring zookeeper"
#configureClusterZookeeper
#restartZookeeper
#echo "Configuring mesos"
#configureMesosphere
#echo "Starting slaves"



