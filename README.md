# mesos-hello-world

Starts up a cluster with mesos, marathon and chronos. It uses docker to configure the mesos master image and the mesos slave image.

How to run
==========

```
./setupCluster.sh <numberOfMasters> <numberOfSlaves>
```

It will first build the docker images for the mesos master and the mesos slave

```
docker build -t mesos_master master
docker build -t mesos_slave slave
```

Create the docker network (172.18.0.0/16 by default)

```
docker network create --subnet=${network} mynetwork
```

Any docker containers with the naming format master* or slave* are stopped.
A backup of /etc/hosts is created and put in the working folder. 
This is done because for every container the ip of the container will be added to /etc/hosts along with its name (for exampel, master1 or slave4).
Then all master and slave containers are started. These images have the ssh deamon running so that we can connect to them and configure mesos, zookeeper, marathon and chronos.

After the script has run mesos will be running on master1:5050 (or any other of the masters depending on which master is elected).
Marathon will be running on master1:8080 and chronos on master1:4400.