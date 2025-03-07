#!/bin/bash

# vars
TEAM_PASSWORD=$(echo $1 | awk '{sub(/\$/,"\\$"); print}')
TEAM_PASSWORD_INITAIL=$1
HIVE_PASSWORD=$(echo $2 | awk '{sub(/\$/,"\\$"); print}')
JN_LIP=$3

# nn
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S apt install postgresql"

ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S -u postgres psql -c \"DROP DATABASE IF EXISTS metastore;\""
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S -u postgres psql -c \"create database metastore;\""
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S -u postgres psql -c \"create user hive with password '$HIVE_PASSWORD';\""
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S -u postgres psql -c \"grant all privileges on database "metastore" to hive;\""
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S -u postgres psql -c \"alter database metastore owner to hive;\""

scp postgresql.conf nn:/home/team
echo "host    metastore       hive            $JN_LIP/32        password">>pg_hba.conf
scp pg_hba.conf nn:/home/team
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S cp postgresql.conf /etc/postgresql/16/main"
ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S cp pg_hba.conf /etc/postgresql/16/main"

ssh nn "echo \"$TEAM_PASSWORD\" | sudo -S systemctl restart postgresql"

# jn
echo "$TEAM_PASSWORD_INITAIL" | sudo -S apt install -y postgresql-client-16