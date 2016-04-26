#!/usr/bin/env bash

if [ -z "$ZK_MESOS" ]; then
  echo "Need to set ZK_MESOS"
  exit 1
fi

if [ -z "$ZK_KAFKA" ]; then
  echo "Need to set ZK_KAFKA"
  exit 1
fi

sed -i 's|master=master:5050|master='"$ZK_MESOS"'|g' /kafka/kafka-mesos.properties
sed -i 's|zk=master:2181/chroot|zk='"$ZK_KAFKA"'|g' /kafka/kafka-mesos.properties
sed -i 's|user=vagrant|user=root|g' /kafka/kafka-mesos.properties
sed -i 's|api=http://192.168.3.5:7000|api=http://mesos-slave-1:7000|g' /kafka/kafka-mesos.properties

sed -i 's|"zk": "zk://127.0.0.1:2181/mesos",|"zk": "'"$ZK_MESOS"'",|g' $GOPATH/src/github.com/mesosphere/mesos-dns/config.json
sed -i 's|"masters": \["127.0.0.1:5050"\],|"masters": \["mesos-master-1:5050"\],|g' $GOPATH/src/github.com/mesosphere/mesos-dns/config.json

exec "$@"