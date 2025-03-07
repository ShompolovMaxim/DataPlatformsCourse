#!/bin/bash

#vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_IP=$2
DB=$3
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "export HADOOP_HOME=/home/hadoop/hadoop-3.4.0 && /home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/beeline -u jdbc:hive2://jn:5433 -n scott -p tiger -e \"create database IF NOT EXISTS $DB; SET hive.exec.dynamic.partition = true; SET hive.exec.dynamic.partition.mode = nonstrict;\""
