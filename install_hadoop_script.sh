#!/bin/bash
tar -xzvf hadoop-3.4.0.tar.gz

chmod 777 .profile
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export HADOOP_HOME=/home/hadoop/hadoop-3.4.0" >> .profile
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0 >> .bashrc
echo "export JAVA_HOME=$JAVA_HOME" >> .profile
export JAVA_HOME=$JAVA_HOME >> .bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> .profile
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin >> .bashrc

echo "export JAVA_HOME=$JAVA_HOME" >> hadoop-3.4.0/etc/hadoop/hadoop-env.sh

echo '<?xml version="1.0" encoding="UTF-8"?>' > hadoop-3.4.0/etc/hadoop/core-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> hadoop-3.4.0/etc/hadoop/core-site.xml
echo "<configuration><property><name>fs.defaultFS</name><value>hdfs://nn:9000</value></property></configuration>" >> hadoop-3.4.0/etc/hadoop/core-site.xml

echo '<?xml version="1.0" encoding="UTF-8"?>' > hadoop-3.4.0/etc/hadoop/hdfs-site.xml
echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> hadoop-3.4.0/etc/hadoop/hdfs-site.xml
echo "<configuration><property><name>dfs.replication</name><value>3</value></property></configuration>" >> hadoop-3.4.0/etc/hadoop/hdfs-site.xml

echo "nn" > hadoop-3.4.0/etc/hadoop/workers
echo "dn-00" >> hadoop-3.4.0/etc/hadoop/workers
echo "dn-01" >> hadoop-3.4.0/etc/hadoop/workers