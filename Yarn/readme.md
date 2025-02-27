# Используемые обозначения:

* `$USER` - имя пользователя с правами root (team)
* `$JN_IP` - глобальный IP-адрес JN

# Инструкция к скрипту:

## Для запуска развёртывания YARN и публикации веб-интерфейсы основных и вспомогательных демонов кластера для внешнего использования необходимо запустить скрипт `run.sh` со следующими параметрами (слева указаны порядковые номера):

1) Пароль пользователя с правами root (пользователя team)
2) Пароль для пользователя hadoop
3) Имя пользователя с правами root (team)
4) Глобальный IP-адрес JN

## Демоны доступны по следующим адресам в среде, в которой запускается скрипт:
* hadoop: http://localhost:9870
* YARN: http://localhost:8088
* JobHistory: http://localhost:19888

## Пример запуска скрипта:

`sh run.sh password_user password_hadoop_strong team 176.0.0.1`

## Примечания:

* На кластере предварительно должен быть развёрнут hadoop, например, способами, описанными в директории Hadoop этого репозитория
* На кластере предварительно должен быть запущен nginx
* Доступ к веб-интерфейсам имеется, пока поддерживается ssh сессия, открывающаяся после завершения работы скрипта. Для переподключения требуется перезапустить скрипт или выполнить команду `ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 $USER@$JN_IP`

# Инструкция по развётрыванию YARN без скрипта:

1) Подключиться к edge-ноде по ssh: `ssh $USER@$JN_IP`
2) Подключиться к пользователю hadoop: `sudo -i -u hadoop`
3) В файле `hadoop-3.4.0/etc/hadoop/yarn-site.xml` добавить конфигурацию:

        <configuration>
            <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
            </property>
            <property>
                <name>yarn.nodemanager.env-whitelist</name>
                <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
            </property>
            <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>nn</value>
            </property>
            <property>
                <name>yarn.resourcemanager.address</name>
                <value>nn:8032</value>
            </property>
            <property>
                <name>yarn.resourcemanager.resource-tracker.address</name>
                <value>nn:8031</value>
            </property>
        </configuration>
4) В файле `hadoop-3.4.0/etc/hadoop/mapred-site.xml` добавить конфигурацию:

        <configuration>
            property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
            </property>
            <property>
                <name>mapreduce.application.classpath</name>
                <value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
            </property>
        </configuration>
5) Перенести данные конфигурации на остальные ноды (пример для одной ноды):
* `scp /home/hadoop/hadoop-3.4.0/etc/hadoop/yarn-site.xml $OTHER_NODE:/home/hadoop/hadoop-3.4.0/etc/hadoop`
* `scp /home/hadoop/hadoop-3.4.0/etc/hadoop/mapred-site.xml $OTHER_NODE:/home/hadoop/hadoop-3.4.0/etc/hadoop`

где `$OTHER_NODE` - адрес другой ноды (например, `nn` или `team@$IP`)

6) Перейти на namenode-у и запустить YARN: `hadoop-3.4.0/sbin/start-yarn.sh` (в домашней директории)

# Инструкция по развётрыванию historyserver без скрипта:

На namenode-е от пользователя hadoop: `mapred --daemon start historyserver`

# Инструкция по публикации веб-интерфейсы основных и вспомогательных демонов кластера для внешнего использования без скрипта:

1) Подключиться к edge-ноде по ssh: `ssh $USER@$JN_IP`
2) Добавить (или отредактировать) в директорию `/etc/nginx/sites-available` следующие файлы:
* `nn` (для hadoop) c конфигурацией:

        server {

            listen 9870;

            root /var/www/html;

            index index.html index.htm index.nginx-debian.html;

            server_name _;

            location / {
                    proxy_pass http://nn:9870;
            }
        }

* `ya` (для YARN) c конфигурацией:

        server {

            listen 8088;

            root /var/www/html;

            index index.html index.htm index.nginx-debian.html;

            server_name _;

            location / {
                    proxy_pass http://nn:8088;
            }
        }

* `dh` (для JobHistory) c конфигурацией:

        server {

            listen 19888;

            root /var/www/html;

            index index.html index.htm index.nginx-debian.html;

            server_name _;

            location / {
                    proxy_pass http://nn:19888;
            }
        }

3) Создать ссылки на эти файлы в директории `/etc/nginx/sites-enabled`:

* `sudo ln -s /etc/nginx/sites-available/nn  /etc/nginx/sites-enabled/nn`
* `sudo ln -s /etc/nginx/sites-available/ya  /etc/nginx/sites-enabled/ya`
* `sudo ln -s /etc/nginx/sites-available/dh  /etc/nginx/sites-enabled/dh`

4) Перезагрузить nginx: `sudo systemctl reload nginx`
5) Выйти из ssh сессии на своё устнойство
6) Подключиться к edge-ноде c отображением портов: `ssh -L 9870:127.0.0.1:9870 -L 8088:127.0.0.1:8088 -L 19888:127.0.0.1:19888 $USER@$JN_IP`

