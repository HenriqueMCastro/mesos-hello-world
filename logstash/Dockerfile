FROM library/logstash:5.0

# install java 8
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
#RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
#RUN apt-get update
#RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#RUN apt-get -y install oracle-java8-installer
#RUN apt-get -y install oracle-java8-set-default
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

WORKDIR /opt/logstash/bin

RUN logstash-plugin install logstash-codec-gzip_lines
RUN logstash-plugin install logstash-output-webhdfs

# hdfs client
RUN wget  http://apache.mirrors.pair.com/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz
RUN tar -xvf hadoop-2.7.2.tar.gz
RUN mv hadoop-2.7.2 /usr/local/hadoop

ENV HADOOP_USER_NAME logstash
ENV HADOOP_INSTALL /usr/local/hadoop
ENV PATH $PATH:$HADOOP_INSTALL/bin
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_INSTALL/lib/native
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_INSTALL/lib"



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

#RUN apt-get update && \
#    apt-get install -y git && \
#    git clone https://github.com/tan-tan-kanarek/logstash-input-gzfile.git

#RUN cd logstash-input-gzfile &
#    sudo ./install.sh

#RUN apt-get install -y rubygems
#RUN git clone https://github.com/tan-tan-kanarek/logstash-input-gzfile.git /opt/logstash-input-gzfile
#WORKDIR /opt/logstash-input-gzfile
#RUN gem build /opt/logstash-input-gzfile/logstash-input-file.gemspec
#RUN /opt/logstash/bin/plugin install /opt/logstash-input-gzfile/logstash-input-gzfile-1.0.0.gem

ADD core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml
COPY logstash.conf /opt/logstash/config

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/logstash/bin/logstash", "-f", "/opt/logstash/config", "--debug"]

#CMD ["sleep","10000000"]