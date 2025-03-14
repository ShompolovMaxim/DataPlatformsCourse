#!/bin/bash

#vars
TEAM_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
HADOOP_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')
USER=$3
JN_IP=$4
JN_LIP=$5

# jn team
sshpass -p $TEAM_PASSWORD ssh -t $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S apt install -y python3-venv"
sshpass -p $TEAM_PASSWORD ssh -t $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S apt install -y python3-pip"

# jn hadoop
sshpass -p $HADOOP_PASSWORD scp jn_hadoop_script.sh hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "bash /home/hadoop/jn_hadoop_script.sh \"$HADOOP_PASSWORD\" $JN_LIP"