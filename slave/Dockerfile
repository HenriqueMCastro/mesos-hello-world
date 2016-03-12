FROM ubuntu:14.04

# install docker
# Let's start with some basic stuff.
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

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF 
RUN echo deb http://repos.mesosphere.io/ubuntu trusty main > /etc/apt/sources.list.d/mesosphere.list
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

# install mesos, marathon and chronos
RUN apt-get -y install mesos

#RUN apt-get -y install apt-transport-https ca-certificates
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#RUN echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list
#RUN apt-get update
#RUN apt-get purge lxc-docker
#RUN apt-cache policy docker-engine
#RUN apt-get -y install linux-image-extra-`$(uname -r)`
#RUN apt-get -y install apparmor
#RUN apt-get -y install docker-engine
#RUN service docker start
# Update slave configuration to specify the use of the Docker containerizer 
RUN echo 'docker,mesos' > /etc/mesos-slave/containerizers

# Increase the executor timeout to account for the potential delay in pulling a docker image to the slave.
RUN echo '5mins' > /etc/mesos-slave/executor_registration_timeout

EXPOSE 2181
EXPOSE 2888
EXPOSE 3888
EXPOSE 5051

CMD ["/usr/sbin/sshd", "-D"]
