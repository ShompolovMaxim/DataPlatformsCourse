# Инструкция к скрипту:

## Для запуска развёртывания Apache Spark под управлением YARN и подготовки окружения для использования виртуальной среды необходимо запустить скрипт `run.sh` со следующими параметрами (слева указаны порядковые номера):

1) Пароль пользователя с правами root (пользователя team)
2) Пароль для пользователя hadoop
3) Имя пользователя с правами root (team)
4) Глобальный IP-адрес JN
5) Локальный IP-адрес JN

## Пример запуска скрипта:

`sh run.sh password_user password_hadoop_strong team 176.0.0.1 192.168.1.2`

## Примечания:

* На кластере предварительно должен быть развёрнуты Hadoop, YARN и Hive, например, способами, описанными в директориях Hadoop, Yarn и Hive этого репозитория соответственно
* На машине, на которой запускаются скрипты должен быть установлен sshpass
* Пароли должны передаваться в виде, воспринимаемом bash, то есть, например, знаки $ должны быть экранированы

# Инструкция по развёртыванию Apache Spark под управлением YARN и подготовке окружения для использования виртуальной среды:

## Используемые обозначения:

* `$USER` - имя пользователя с правами root (team)
* `$JN_IP` - глобальный IP-адрес JN
* `$JN_LIP` - локальный IP-адрес JN

## Действия:

1) Подключиться к edge-ноде по ssh под пользователем с правами администратора: `ssh $USER@$JN_IP`

2) Установить venv: `sudo apt install python3-venv`

3) Установить pip: `sudo apt install python3-pip`

4) Перейти в пользователя hadoop: `sudo -i -u hadoop`

5) Скачать Spark: `wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz`

6) Распаковать Spark: `tar -xzvf spark-3.5.3-bin-hadoop3.tgz`

7) Установить переменные окружения:

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

8) Применить изменения переменных окружения: `source .profile`

9) Создать виртуальное окружение: `python3 -m venv venv`

10) Активировать виртуальное окружение: `source venv/bin/activate`

11) Обновить pip: `pip install -U pip`

12) Установить ipython: `pip install ipython`

13) Установить onetl: `pip install onetl[files]`

14) Запустить сервис metastore: `hive --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enabled=false --service metastore 1>> /tmp/ms.log 2>> /tmp/ms.log`
