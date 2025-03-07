#!/bin/bash

#vars
HADOOP_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
JN_IP=$2
DB=$3
TABLE=$4
CREATE_TABLE=$5
DATA=$6

sh create_db.sh $HADOOP_PASSWORD $2 $3
sh fill_table.sh $HADOOP_PASSWORD $2 $4 $5 $6
