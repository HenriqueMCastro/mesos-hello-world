FROM java:8

# mesosphere ubuntu repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list
RUN apt-get update

# install marathon
RUN apt-get -y install mesos marathon

EXPOSE 8080

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD marathon --master $ZK_MESOS --hostname $HOSTNAME --task_launch_timeout 300000 --logging_level info --webui_url $WEB_UI_URL
#CMD /usr/lib/jvm/java-8-openjdk-amd64/bin/java -Djava.library.path=/usr/local/lib:/usr/lib:/usr/lib64 -Djava.util.logging.SimpleFormatter.format=%2$s%5$s%6$s%n -Xmx512m -cp /usr/bin/marathon mesosphere.marathon.Main --master "zk://zookeeper-node-1:2181,zookeeper-node-2:2181,zookeeper-node-3:2181/mesos" --hostname marathon --task_launch_timeout 300000 --logging_level info