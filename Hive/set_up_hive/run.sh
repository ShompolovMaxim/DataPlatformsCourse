#!/bin/bash

#vars
TEAM_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
HADOOP_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')
HIVE_PASSWORD=$(echo $3 | awk '{sub(/\$/,"\\$"); print}')
USER=$4
JN_IP=$5
JN_LIP=$6

# jn team
sshpass -p $TEAM_PASSWORD scp pg_hba.conf $USER@$JN_IP:/home/team
sshpass -p $TEAM_PASSWORD scp postgresql.conf $USER@$JN_IP:/home/team
sshpass -p $TEAM_PASSWORD scp jn_team_script.sh $USER@$JN_IP:/home/team
sshpass -p $TEAM_PASSWORD ssh -t $USER@$JN_IP "sh /home/team/jn_team_script.sh \"$TEAM_PASSWORD\" \"$HIVE_PASSWORD\" $JN_LIP"

# jn hadoop
sshpass -p $HADOOP_PASSWORD scp jn_hadoop_script.sh hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD scp hive-site.xml hadoop@$JN_IP:/home/hadoop
sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "bash /home/hadoop/jn_hadoop_script.sh \"$HADOOP_PASSWORD\" \"$HIVE_PASSWORD\""
