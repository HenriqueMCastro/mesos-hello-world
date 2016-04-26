#!/bin/bash

docker ps -a -q --filter=name=zookeeper-node-* | xargs -n 1 -I {} docker rm -f --volumes {}
