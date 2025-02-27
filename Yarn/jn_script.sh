#!/bin/bash

HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')

scp /home/hadoop/hadoop-3.4.0/etc/hadoop/yarn-site.xml nn:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp /home/hadoop/hadoop-3.4.0/etc/hadoop/mapred-site.xml nn:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp /home/hadoop/hadoop-3.4.0/etc/hadoop/yarn-site.xml dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp /home/hadoop/hadoop-3.4.0/etc/hadoop/mapred-site.xml dn-00:/home/hadoop/hadoop-3.4.0/etc/hadoop

scp /home/hadoop/hadoop-3.4.0/etc/hadoop/yarn-site.xml dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop
scp /home/hadoop/hadoop-3.4.0/etc/hadoop/mapred-site.xml dn-01:/home/hadoop/hadoop-3.4.0/etc/hadoop

ssh nn "hadoop-3.4.0/sbin/start-yarn.sh"
ssh nn "/home/hadoop/hadoop-3.4.0/bin/mapred --daemon start historyserver"