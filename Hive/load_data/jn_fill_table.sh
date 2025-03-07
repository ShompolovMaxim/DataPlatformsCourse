#!/bin/bash

HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
TABLE=$2
CREATE_TEABLE=$3
DATA=$4
HADOOP_HOME=/home/hadoop/hadoop-3.4.0

hadoop-3.4.0/bin/hdfs dfs -mkdir -p /load_data
hadoop-3.4.0/bin/hdfs dfs -put $DATA /load_data
export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/beeline -u jdbc:hive2://jn:5433 -n scott -p tiger -f $CREATE_TEABLE
/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/beeline -u jdbc:hive2://jn:5433 -n scott -p tiger -e "load data inpath '/load_data/$DATA' into table $TABLE;"