#!/bin/bash
USER=$3
JN_IP=$4
JN_LIP=$5
NN_LIP=$6
DN0_LIP=$7
DN1_LIP=$8
scp jn_script.sh $USER@$JN_IP:/home/$USER
scp configure_node_script.sh $USER@$JN_IP:/home/$USER
scp install_hadoop_script.sh $USER@$JN_IP:/home/$USER
scp hadoop_user_script.sh $USER@$JN_IP:/home/$USER
HADOOP_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')
TEAM_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
ssh -t $USER@$JN_IP "sh /home/$USER/jn_script.sh \"$HADOOP_PASSWORD\" \"$TEAM_PASSWORD\" $USER $JN_LIP $NN_LIP $DN0_LIP $DN1_LIP"

sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "sh /home/hadoop/hadoop_user_script.sh \"$HADOOP_PASSWORD\""