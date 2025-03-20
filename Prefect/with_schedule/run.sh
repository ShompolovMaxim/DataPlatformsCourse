#!/bin/bash

#vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_IP=$2
MODE=$3

# jn team
sshpass -p $HADOOP_PASSWORD scp flow.py hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD scp jn_script.sh hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "bash jn_script.sh $MODE"