#!/bin/bash

#vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_IP=$2
TABLE=$3
CREATE_TABLE=$4
DATA=$5


sshpass -p $HADOOP_PASSWORD scp $DATA hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD scp $CREATE_TABLE hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD scp jn_fill_table.sh hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "bash /home/hadoop/jn_fill_table.sh \"$HADOOP_PASSWORD\" $TABLE $CREATE_TABLE $DATA"
#sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "beeline -u jdbc:hive2://jn:5433 -n scott -p tiger -e \"create database $DB;\""

