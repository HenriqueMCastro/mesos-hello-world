"""
 Counts words in UTF8 encoded, '\n' delimited text received from the network every second.
 Usage: network_wordcount.py <hostname> <port>
   <hostname> and <port> describe the TCP server that Spark Streaming would connect to receive data.
 To run this on your local machine, you need to first run a Netcat server
    `$ nc -lk 9999`
 and then run the example
    `$ bin/spark-submit examples/src/main/python/streaming/network_wordcount.py localhost 9999`
"""
from __future__ import print_function

import sys

from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

if __name__ == "__main__":
    sc = SparkContext(master="local", appName="PythonHelloWorld")
    ssc = StreamingContext(sc, 10)

    directKafkaStream = KafkaUtils.createDirectStream(ssc, [], {"metadata.broker.list": "mesos-slave-1:31000,mesos-slave-2:31000,mesos-slave-3:31000"})

    lines = ssc.textFileStream("/user/hdecastro/")
    lines.pprint()
    lines.count().pprint()
    # counts = lines.flatMap(lambda line: line.split(" ")) \
    #     .map(lambda word: (word, 1)) \
    #     .reduceByKey(lambda a, b: a+b)
    # print(counts)
    # print(type(counts))
    # type(counts)
    #
    # counts.pprint()

    print("Hello world")

    ssc.start()
    ssc.awaitTermination()