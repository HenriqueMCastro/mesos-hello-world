FROM sequenceiq/spark:1.6.0

COPY hello-world.py /

COPY data.txt /data.txt

COPY core-site.xml /core-site.xml

RUN rm /usr/local/hadoop/etc/hadoop/core-site.xml && \
    mv /core-site.xml /usr/local/hadoop/etc/hadoop/

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["sleep", "1000000"]
