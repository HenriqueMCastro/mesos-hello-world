FROM java:8

# install git
#RUN apt-get install -y software-properties-common
#RUN add-apt-repository ppa:git-core/ppa -y
#RUN apt-get update
#RUN apt-get install -y git

RUN mkdir ~/Downloads && \
	cd ~/Downloads && \
	git clone https://github.com/yahoo/kafka-manager.git 

RUN cd ~/Downloads/kafka-manager && \
	echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt 
RUN cd ~/Downloads/kafka-manager && \
	./sbt clean dist
RUN unzip  -d / ~/Downloads/kafka-manager/target/universal/kafka-manager-1.3.0.8.zip

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/kafka-manager-1.3.0.8/bin/kafka-manager", "-Dconfig.file=/kafka-manager-1.3.0.8/conf/application.conf"]




