#!/bin/bash
mkdir .ssh
rm .ssh/id_rsa
ssh-keygen -t rsa -N '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
ssh-keyscan nn >> ~/.ssh/known_hosts
ssh-keyscan dn-00 >> ~/.ssh/known_hosts
ssh-keyscan dn-01 >> ~/.ssh/known_hosts
sshpass -p $1 scp -o "CheckHostIP=no" -r .ssh nn:/home/hadoop
sshpass -p $1 scp -o "CheckHostIP=no" -r .ssh dn-00:/home/hadoop
sshpass -p $1 scp -o "CheckHostIP=no" -r .ssh dn-01:/home/hadoop

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
scp hadoop-3.4.0.tar.gz nn:/home/hadoop
scp hadoop-3.4.0.tar.gz dn-00:/home/hadoop
scp hadoop-3.4.0.tar.gz dn-01:/home/hadoop

sh install_hadoop_script.sh
chmod 777 .profile
source .profile

scp install_hadoop_script.sh nn:/home/hadoop
scp install_hadoop_script.sh dn-00:/home/hadoop
scp install_hadoop_script.sh dn-01:/home/hadoop

ssh nn "sh install_hadoop_script.sh"
ssh nn "source .profile"
ssh dn-00 "sh install_hadoop_script.sh"
ssh dn-00 "source .profile"
ssh dn-01 "sh install_hadoop_script.sh"
ssh dn-01 "source .profile"

ssh nn 'hadoop-3.4.0/bin/hdfs namenode -format'
ssh nn 'hadoop-3.4.0/sbin/start-dfs.sh'