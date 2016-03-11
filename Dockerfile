FROM ubuntu:14.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-get update

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

# install openssh
RUN apt-get install -y openssh-server
#RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# install java 8
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer
RUN apt-get -y install oracle-java8-set-default

# install some extras
RUN dpkg-reconfigure locales && \
    locale-gen en_GB.UTF-8 && \
    /usr/sbin/update-locale LANG=en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8
RUN apt-get -y install lsof
RUN apt-get -y install telnet

# install mesos
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF 
RUN echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list 
RUN apt-get update 
RUN apt-get -y install mesos=0.24.1-0.2.35.ubuntu1404

EXPOSE 2181
EXPOSE 2888
EXPOSE 3888

CMD ["/usr/sbin/sshd", "-D"]
