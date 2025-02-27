#!/bin/bash

JN_LIP=$3
NN_LIP=$4
DN0_LIP=$5
DN1_LIP=$6
#sudo echo "127.0.0.1 dn-00" > /etc/hosts
sudo echo "$JN_LIP jn" > /etc/hosts
sudo echo "$NN_LIP nn" >> /etc/hosts
sudo echo "$DN0_LIP dn-00" >> /etc/hosts
sudo echo "$DN1_LIP dn-01" >> /etc/hosts
sudo echo $1 > /etc/hostname

#sudo adduser -u hadoop -p $2
#sudo useradd -m hadoop -p $2

#useradd -m -U hadoop
#echo "hadoop:$2" | chpasswd

#useradd -m -p $(openssl passwd -1 $2) hadoop
sudo adduser hadoop
apt-get install sshpass