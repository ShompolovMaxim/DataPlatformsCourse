# Инструкция к скрипту:

## Для запуска развёртывания Hive необходимо запустить скрипт `run.sh` со следующими параметрами (слева указаны порядковые номера):

1) Пароль пользователя с правами root (пользователя team)
2) Пароль для пользователя hadoop
3) Пароль для пользователя базы данных metastore
4) Имя пользователя с правами root (team)
5) Глобальный IP-адрес JN
6) Локальный IP-адрес JN

## Пример запуска скрипта:

`sh run.sh password_user password_hadoop_strong password_hive team 176.0.0.1 192.168.1.2`

## Примечания:

* На кластере предварительно должен быть развёрнуты Hadoop и YARN, например, способами, описанными в директориях Hadoop и Yarn этого репозитория соответственно
* На машине, на которой запускаются скрипты должен быть установлен sshpass
* Пароли должны передаваться в виде, воспринимаемом bash, то есть, например, знаки $ должны быть экранированы

# Инструкция по развётрыванию Hive без скрипта:

## Используемые обозначения:

* `$USER` - имя пользователя с правами root (team)
* `$JN_IP` - глобальный IP-адрес JN
* `$JN_LIP` - локальный IP-адрес JN
* `$HIVE_PASSWORD` - пароль пользователя БД hive

## Действия:

1) Подключиться к edge-ноде по ssh: `ssh $USER@$JN_IP`

2) Подключиться к namenode: `ssh nn`

3) Установить postgresql: `sudo apt install postgresql`

4) Переключиться на пользователя postgres: `sudo -i -u postgres`

5) Зайти в psql: `psql`

6) Создать базу данных `metastore` (она позволит нам одновременного использовать Hive более чем одним клиентом): `create database metastore;`

7) Создать пользователя hive: `create user hive with password '$HIVE_PASSWORD';`

8) Предоставить пользователю hive привилении на использование базы данных metastore: `grant all privileges on database "metastore" to hive;`

9) Сделать пользователя hive владельцем базы данных metastore: `alter database metastore owner to hive;`

10) Вернуться в пользователя team

11) Отредактировать файл `/etc/postgresql/16/main/postgresql.conf`, добавив параметр `listen_addresses = 'nn'` в соответствующем месте раздела `CONNECTIONS AND AUTHENTICATION`, подраздела `Connection Settings` (именно в это место для читаемости и простоты последующей отладки). Параметр `port` должен быть равен `5432`

12) Отредактировать файл `/etc/postgresql/16/main/pg_hba.conf`, добавив в раздел `IPv4 local connections:` (для читаемости) строки:

* `host    metastore       hive            192.168.1.1/32          password`
* `host    metastore       hive            $JN_LIP/32              password`

13) Перезапустить postgresql: `sudo systemctl restart postgresql`

14) Вернуться на edge-node и установить соответствующий postgresql-client: `sudo apt install postgresql-client-16`

15) Подключиться к пользователю hadoop: `sudo -i -u hadoop`

16) Скачать соответствующий дистрибутив hive: `wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz`

17) Распаковать соответствующий дистрибутив hive: `tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz`

18) Скачать JDBC драйвер для postgresql: `wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar -P /home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib`

19) Создать файл `apache-hive-4.0.0-alpha-2-bin/conf/hive-site.xml` со следующей конфигурацией:

    
        <configuration> 
            <property>
                <name>hive.server2.authentication</name>
                <value>NONE</value>
            </property>
            <property>
                <name>hive.metastore.warehouse.dir</name>
                <value>/user/hive/warehouse</value>
            </property>
            <property>
                <name>hive.server2.thrift.port</name>
                <value>5433</value>
                <description>TCP port number to listen on, default 10000</description>
            </property>
            <property>
                <name>javax.jdo.option.ConnectionURL</name>
                <value>jdbc:postgresql://nn:5432/metastore</value>
            </property>
            <property>
                <name>javax.jdo.option.ConnectionDriverName</name>
                <value>org.postgresql.Driver</value>
            </property>
            <property>
                <name>javax.jdo.option.ConnectionUserName</name>
                <value>hive</value>
            </property>
            <property>
                <name>javax.jdo.option.ConnectionPassword</name>
                <value>$HIVE_PASSWORD</value>
            </property>
        </configuration>

20) Добавить необходимые переменные окружения, дописав соответствующие строки в файл `/home/hadoop/profile`:

        export HIVE_HOME=/home/hadoop/apache-hive-4.0.0-alpha-2-bin
        export HIVE_CONF_DIR=$HIVE_HOME/conf
        export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
        export PATH=$PATH:$HIVE_HOME/bin

21) Применить изменения переменных окружения: `source .profile`

22) Проверить наличие в HDFS директории `tmp`: `hdfs dfs -ls /`

23) При её отсутствии - создать: `hdfs dfs -mkdir -p /tmp`

24) Создать в HDFS директорию `/user/hive/warehouse`: `hdfs dfs -mkdir -p /user/hive/warehouse`

25) Выдать права на директорию `tmp`: `hdfs dfs -chmod g+w /tmp`

26) Выдать права на директорию `/user/hive/warehouse`: `hdfs dfs -chmod g+w /user/hive/warehouse`

27) Инициализировать схему Hive metastore в postgres: `apache-hive-4.0.0-alpha-2-bin/bin/schematool -dbType postgres -initSchema`

28) Запустить hive: `hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service hiveserver2 1>> /tmp/hs2.log 2>> /tmp/hs2.log &`