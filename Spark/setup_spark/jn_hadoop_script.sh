#!/bin/bash

# vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_LIP=$2

wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
tar -xzvf spark-3.5.3-bin-hadoop3.tgz

echo 'export HADOOP_CONF_DIR="/home/hadoop/hadoop-3.4.0/etc/hadoop"' >> .profile
echo 'export HIVE_HOME="/home/hadoop/apache-hive-4.0.0-alpha-2-bin"' >> .profile
echo 'export HIVE_CONF_DIR=$HIVE_HOME/conf' >> .profile
echo 'export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*' >> .profile
echo 'export PATH=$PATH:$HIVE_HOME/bin' >> .profile
echo "export SPARK_LOCAL_IP=$JN_LIP" >> .profile
echo 'export SPARK_DIST_CLASSPATH="/home/hadoop/spark-3.5.3-bin-hadoop3/jars/*:/home/hadoop/hadoop-3.4.0/etc/hadoop:/home/hadoop/hadoop-3.4.0/share/hadoop/common/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/common/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/*:/home/hadoop/hadoop-3.4.0/share/hadoop/mapreduce/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib/*"' >> .profile
echo 'export SPARK_HOME="/home/hadoop/spark-3.5.3-bin-hadoop3"' >> .profile
echo 'export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):/home/hadoop/venv/lib/python3.12/site-packages:$PYTHONPATH' >> .profile
echo 'export PATH=$SPARK_HOME/bin:$PATH' >> .profile

source .profile

python3 -m venv venv
source venv/bin/activate
pip install -U pip
pip install ipython
pip install onetl[files]

tmux kill-session -t hivemetastore
tmux new-session -d -s hiveserver2 "/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2.log"
tmux new-session -d -s hivemetastore "/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service metastore 1>> /tmp/ms.log 2>> /tmp/ms.log"
sleep 10