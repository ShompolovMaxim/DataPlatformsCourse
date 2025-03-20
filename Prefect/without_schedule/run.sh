#!/bin/bash

#vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_IP=$2

# jn team
sshpass -p $HADOOP_PASSWORD scp flow.py hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "python3 -m venv venv && source .profile && source venv/bin/activate && pip install prefect && python3 flow.py"