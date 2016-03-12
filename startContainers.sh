#!/bin/bash

function timestamp {
	date +%s 
}

function backupHostsFile {
	filename="hosts"$(timestamp)".bak"
	cp /etc/hosts ${filename}
}

function removeContainerIfRunning {
	echo "Checking if container ${1} is running"
      	running=`docker ps -a | grep ${1}`
	if [[ "${running}" != "" ]];
	then
		docker rm -f --volumes=true ${1}
		echo "Stopped docker container with name ${1}"
	fi
}

function removeHost {
	exists=`cat /etc/hosts | grep ${1}`
	if [[ "${exists}" != "" ]];
	then
		sudo sed -i "/${1}/d" /etc/hosts
	fi 
}

function getContainerIp {
	hostname=${1}
	docker inspect ${hostname} | grep IPAddress | cut -d '"' -f 4 | sed '/^$/d' | sed '$!N; /^\(.*\)\n\1$/!P; D'
}

function startMasters {
    echo "Starting up masters docker containers"
    for masterId in `seq 1 ${numberOfMasters}`;
    do
        hostname=master${masterId}
        docker run -d  --privileged --net=mynetwork --name=${hostname} mesos_master
        removeHost ${hostname}
        containerIp=$(getContainerIp ${hostname})
        echo "${containerIp} ${hostname}" | sudo tee -a /etc/hosts
        sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "echo $masterId > /etc/zookeeper/conf/myid"
    done
}

function startSlaves {
    echo "Starting up slaves docker containers"
    for slaveId in `seq 1 ${numberOfSlaves}`;
        do
            hostname=slave${slaveId}
            docker run -d --privileged --net=mynetwork --name=${hostname} mesos_slave
            removeHost ${hostname}
            containerIp=$(getContainerIp ${hostname})
            echo "${containerIp} ${hostname}" | sudo tee -a /etc/hosts
            sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup mesos-slave --hostname=$hostname --ip=$containerIp --master=$zkMesos --log_dir=/var/log/mesos --logging_level=INFO --containerizers=docker,mesos --executor_registration_timeout=5mins > foo.out 2> foo.err < /dev/null &"
            sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup service docker start > foo.out 2> foo.err < /dev/null &"
        done
}


function configureClusterZookeeper {
	echo "Configuring zoo.cfg"
	file="/etc/zookeeper/conf/zoo.cfg"
	for masterId in `seq 1 ${numberOfMasters}`;
        do
            hostname=master${masterId}
            for otherMasterId in `seq 1 ${numberOfMasters}`;
                do
                    otherHostname=master${otherMasterId}
                    ip=$(getContainerIp ${otherHostname})
                    server="server.${otherMasterId}="${ip}":2888:3888"
                    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "echo $server >> $file"
                done
        done
}

function restartZookeeper {
	echo "Restarting zookeeper"
	for masterId in `seq 1 ${numberOfMasters}`;
    do
		hostname="master"${masterId}
		# zookeeper seems to keep the sockets open even after stopping it so we will have to kill it
		sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "ps axf | grep zookeeper | grep -v grep | awk '{print "kill -9 " $1}' | sh"
		sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "service zookeeper start"
	done
	sleep 5
}

function configureMesosphere {
	echo "Configuring zookeeper quorum in mesos"
	zkMesos='zk://'
	for masterId in `seq 1 ${numberOfMasters}`;
        do
            hostname="master"${masterId}
		    hostIp=$(getContainerIp ${hostname})
		    zkMesos=${zkMesos}${hostIp}":2181,"
        done
	zkMesos=${zkMesos::-1}"/mesos"
	echo $zkMesos
	echo "Starting mesos, port 5050"
	quorum=`expr $numberOfMasters / 2 + 1`
	for masterId in `seq 1 ${numberOfMasters}`;
        do
            sleep 1
            hostname="master"${masterId}
		    hostIp=$(getContainerIp ${hostname})
		    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "echo $zkMesos > /etc/mesos/zk; echo $quorum > /etc/mesos-master/quorum"
		    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup mesos-master --hostname=$hostname --ip=$hostIp --zk=$zkMesos --port=5050 --log_dir=/var/log/mesos --registry=in_memory --work_dir=/var/lib/mesos > foo.out 2> foo.err < /dev/null &"
        done
	echo "Starting marathon in master1, port 8080"
	sleep 10
	zkMarathon='zk://'
    for masterId in `seq 1 ${numberOfMasters}`;
        do
                hostname="master"${masterId}
                hostIp=$(getContainerIp ${hostname})
                zkMarathon=${zkMarathon}${hostIp}":2181,"
        done
    zkMarathon=${zkMarathon::-1}"/marathon"
	hostname="master1"
    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "mkdir -p /etc/marathon/conf; touch /etc/marathon/conf/zk; echo $zkMarathon > /etc/marathon/conf/zk"
    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup /usr/bin/marathon --hostname $hostname --task_launch_timeout 300000 --logging_level info > foo.out 2> foo.err < /dev/null &"
	sleep 2
	echo "Starting chronos in master1, port 4400"
    sshpass -p "root" ssh -o StrictHostKeyChecking=no root@"${hostname}" "nohup /usr/bin/chronos --hostname $hostname > foo.out 2> foo.err < /dev/null &"
}

function stopRunningContainers {
    echo "Stopping any running containers"
    for masterId in `seq 1 ${numberOfMasters}`;
        do
                hostname="master"${masterId}
                removeContainerIfRunning ${hostname}
        done
    for slaveId in `seq 1 ${numberOfSlaves}`;
        do
                hostname="slave"${slaveId}
                removeContainerIfRunning ${hostname}
        done
}

numberOfMasters=${1}
numberOfSlaves=${2}
stopRunningContainers
backupHostsFile
startMasters
configureClusterZookeeper
restartZookeeper
configureMesosphere
startSlaves



