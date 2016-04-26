#!/usr/bin/env bash

if [ -z "$ZK_MARATHON" ]; then
  echo "Need to set ZK_MARATHON"
  exit 1
fi

if [ -z "$ZK_MESOS" ]; then
  echo "Need to set ZK_MESOS"
  exit 1
fi

mkdir -p /etc/marathon/conf
echo "${ZK_MARATHON}" >> /etc/marathon/conf/zk

sed -i 's|zk://localhost:2181/mesos|'"$ZK_MESOS"'|g' /etc/mesos/zk

if [ -z "$WEB_UI_URL" ];then
    WEB_UI_URL=http://${HOSTNAME}:8080
fi

exec env ZK_MESOS=$ZK_MESOS WEB_UI_URL=$WEB_UI_URL "$@"