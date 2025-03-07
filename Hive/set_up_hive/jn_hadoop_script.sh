#!/bin/bash

# vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
HIVE_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')

wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar -P /home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib

echo "<value>$HIVE_PASSWORD</value></property></configuration>">>hive-site.xml

cat hive-site.xml > apache-hive-4.0.0-alpha-2-bin/conf/hive-site.xml

echo 'export HIVE_HOME=/home/hadoop/apache-hive-4.0.0-alpha-2-bin' >> .profile
echo 'export HIVE_CONF_DIR=$HIVE_HOME/conf' >> .profile
echo 'export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*' >> .profile
echo 'export PATH=$PATH:$HIVE_HOME/bin' >> .profile
source .profile

hadoop-3.4.0/bin/hdfs dfs -mkdir -p /tmp
hadoop-3.4.0/bin/hdfs dfs -mkdir -p /user/hive/warehouse
hadoop-3.4.0/bin/hdfs dfs -chmod g+w /tmp
hadoop-3.4.0/bin/hdfs dfs -chmod g+w /user/hive/warehouse

apache-hive-4.0.0-alpha-2-bin/bin/schematool -dbType postgres -initSchema
tmux new-session -d -s hiveserver2 "/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2.log"
