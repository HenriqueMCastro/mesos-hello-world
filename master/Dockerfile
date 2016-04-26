FROM java:8

# mesosphere ubuntu repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list
RUN apt-get update

# install mesos, marathon and chronos
RUN apt-get -y install mesos marathon chronos

# mesos UI
EXPOSE 5050
# marathon UI
EXPOSE 8080

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

#CMD ["mesos-master", "--zk=$ZK_HOSTS", "--hostname=$HOSTNAME", "--port=5050", "--log_dir=/var/log/mesos", "--registry=in_memory", "--work_dir=/var/lib/mesos"]


CMD mesos-master --zk=$ZK_MESOS --hostname=$HOSTNAME --port=5050 --log_dir=/var/log/mesos --registry=in_memory --work_dir=/var/lib/mesos
#CMD mesos-master --zk=$ZK_HOSTS --hostname=$HOSTNAME --ip=$IP --port=5050 --log_dir=/var/log/mesos --registry=in_memory --work_dir=/var/lib/mesos
