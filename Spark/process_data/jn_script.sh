#!/bin/bash

source .profile
hadoop-3.4.0/bin/hdfs dfs -mkdir -p input /
hadoop-3.4.0/bin/hdfs dfs -rm /input/ds.csv
hadoop-3.4.0/bin/hdfs dfs -put ds.csv /input
python3 spark.py

# Task 7
/home/hadoop/apache-hive-4.0.0-alpha-2-bin/bin/beeline -u jdbc:hive2://jn:5433 -n scott -p tiger -e "select * from test.partitioned_data limit 10;"
