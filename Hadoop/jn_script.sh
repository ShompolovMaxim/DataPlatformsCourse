#!/bin/bash
PASSWORD=$2
HADOOP_PASSWORD=$1
USER=$3
JN_LIP=$4
NN_LIP=$5
DN0_LIP=$6
DN1_LIP=$7
rm .ssh/id_ed25519
ssh-keygen -N '' -f .ssh/id_ed25519
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
sudo -S sh configure_node_script.sh jn $1 $JN_LIP $NN_LIP $DN0_LIP $DN1_LIP

sshpass -p $PASSWORD scp -r .ssh $USER@$NN_LIP:/home/$USER
sshpass -p $PASSWORD scp -r .ssh $USER@$DN0_LIP:/home/$USER
sshpass -p $PASSWORD scp -r .ssh $USER@$DN1_LIP:/home/$USER

scp configure_node_script.sh $USER@$NN_LIP:/home/$USER
scp configure_node_script.sh $USER@$DN0_LIP:/home/$USER
scp configure_node_script.sh $USER@$DN1_LIP:/home/$USER

PASSWORD=$(echo $PASSWORD | awk '{sub(/\$/,"\\$"); print}')
ssh $USER@$NN_LIP "sudo -S sh configure_node_script.sh nn \"$HADOOP_PASSWORD\" $JN_LIP $NN_LIP $DN0_LIP $DN1_LIP"
ssh $USER@$DN0_LIP "sudo -S sh configure_node_script.sh 'dn-00' \"$HADOOP_PASSWORD\" $JN_LIP $NN_LIP $DN0_LIP $DN1_LIP"
ssh $USER@$DN1_LIP "sudo -S sh configure_node_script.sh 'dn-01' \"$HADOOP_PASSWORD\" $JN_LIP $NN_LIP $DN0_LIP $DN1_LIP"

sudo cp hadoop_user_script.sh /home/hadoop/
sudo cp install_hadoop_script.sh /home/hadoop/
sudo chmod 777 /home/hadoop/hadoop_user_script.sh
