#!/usr/bin/env bash

if [ -z "$ZK_MESOS" ]; then
  echo "Need to set ZK_MESOS"
  exit 1
fi

sed -i 's|zk://localhost:2181/mesos|'"$ZK_MESOS"'|g' /etc/mesos/zk

if [ -n "$MESOS_MASTER_QUORUM" ]; then
        sed -i 's|1|'"$MESOS_MASTER_QUORUM"'|g' /etc/mesos-master/quorum
fi

if [ -n "$ZK_MARATHON" ]; then
        mkdir -p /etc/marathon/conf
        echo "${ZK_MARATHON}" >> /etc/marathon/conf/zk
fi


#export IP=`grep $HOSTNAME /etc/hosts | awk '{print $1}'`

exec env ZK_MESOS=$ZK_MESOS "$@"