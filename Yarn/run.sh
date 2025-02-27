#!/bin/bash

#vars
TEAM_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
HADOOP_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')
USER=$3
JN_IP=$4

#yarn
sshpass -p $HADOOP_PASSWORD scp yarn-site.xml hadoop@$JN_IP:/home/hadoop/hadoop-3.4.0/etc/hadoop
sshpass -p $HADOOP_PASSWORD scp mapred-site.xml hadoop@$JN_IP:/home/hadoop/hadoop-3.4.0/etc/hadoop
sshpass -p $HADOOP_PASSWORD scp jn_script.sh hadoop@$JN_IP:/home/hadoop

sshpass -p $HADOOP_PASSWORD ssh -t hadoop@$JN_IP "sh /home/hadoop/jn_script.sh \"$HADOOP_PASSWORD\""

#web
scp nn $USER@$JN_IP:/home/team
scp ya $USER@$JN_IP:/home/team
scp dh $USER@$JN_IP:/home/team

ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S cp nn /etc/nginx/sites-available"
ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S cp ya /etc/nginx/sites-available"
ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S cp dh /etc/nginx/sites-available"

ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S ln -s /etc/nginx/sites-available/nn  /etc/nginx/sites-enabled/nn"
ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S ln -s /etc/nginx/sites-available/ya  /etc/nginx/sites-enabled/ya"
ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S ln -s /etc/nginx/sites-available/dh  /etc/nginx/sites-enabled/dh"

ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S systemctl reload nginx"
#ssh $USER@$JN_IP "echo \"$TEAM_PASSWORD\" | sudo -S systemctl restart nginx"

ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 $USER@$JN_IP

