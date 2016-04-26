FROM ubuntu:14.04

ENV TERM dumb

# install docker
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
CMD ["wrapdocker"]

#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF 
RUN echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list
RUN apt-get update

# install mesos
RUN apt-get -y install mesos

# Update slave configuration to specify the use of the Docker containerizer 
RUN echo 'docker,mesos' > /etc/mesos-slave/containerizers

# Increase the executor timeout to account for the potential delay in pulling a docker image to the slave.
RUN echo '5mins' > /etc/mesos-slave/executor_registration_timeout

EXPOSE 5051

RUN wget  http://apache.mirrors.pair.com/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
RUN tar -xvf hadoop-2.7.2.tar.gz
RUN mv hadoop-2.7.2 /usr/local/hadoop

ENV HADOOP_USER_NAME chronos
ENV HADOOP_INSTALL /usr/local/hadoop
ENV PATH $PATH:$HADOOP_INSTALL/bin
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_INSTALL/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_INSTALL/lib"
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

ADD core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml

RUN useradd -ms /bin/bash chronos

RUN mkdir -p /etc/hadoop && touch /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_INSTALL=/usr/local/hadoop" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_USER_NAME=chronos" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_OPTS=-Djava.library.path=/usr/local/hadoop/lib" >> /etc/hadoop/hadoop-env.sh && \
	echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> /etc/hadoop/hadoop-env.sh  && \
	echo "export PATH=$PATH:$HADOOP_INSTAQLL/bin" >> /etc/hadoop/hadoop-env.sh && \
	echo "export PATH=$PATH:$HADOOP_INSTALL/sbin" >> /etc/hadoop/hadoop-env.sh 
RUN chown -R chronos /etc/hadoop
RUN mkdir -p /data/tmp/chronos
RUN chown -R chronos /data

RUN wget http://apache.mirror.anlx.net/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz

# kafka
#RUN apt-get install -y wget
#RUN wget "http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz" -O kafka.tgz && \
#	tar -xf kafka.tgz && \
#	mv kafka_2.11-0.9.0.1 kafka

RUN	git clone https://github.com/mesos/kafka
RUN cd kafka && \
    ./gradlew jar
RUN cd kafka && \
    wget "http://mirror.cc.columbia.edu/pub/software/apache/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz"
    #wget https://archive.apache.org/dist/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz

ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so
COPY mx4j-tools.jar /kafka/libs
ENV JMX_PORT 9999

EXPOSE 7000 9999

# mesos-dns
RUN wget https://github.com/mesosphere/mesos-dns/archive/v0.5.2.tar.gz
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-lxc/lxd-stable && \
    apt-get update && \
    apt-get install -y golang
ENV GOPATH $HOME/go
RUN go get github.com/tools/godep && \
    go get github.com/mesosphere/mesos-dns
RUN cd $GOPATH/src/github.com/mesosphere/mesos-dns && \
    $GOPATH/bin/godep go build . && \
    cp config.json.sample config.json

EXPOSE 9092

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD mesos-slave --hostname=$HOSTNAME --master=$ZK_MESOS --log_dir=/var/log/mesos --logging_level=INFO --containerizers=docker,mesos --executor_registration_timeout=5mins

