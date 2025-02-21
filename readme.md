# Инструкция к скрипту:

## Для запуска развёртывания кластера hadoop необходимо запустить скрипт run.sh со следующими параметрами (слева указаны порядковые номера):

1) Пароль пользователя с правами root (пользователя team)
2) Пароль для пользователя hadoop
3) Имя пользователя с правами root (team)
4) Глобальный IP-адрес JN
5) Локальный  IP-адрес JN
6) Локальный  IP-адрес NN
7) Локальный  IP-адрес DN-00
8) Локальный  IP-адрес DN-01

## Пример:

sh run.sh password_user password_hadoop_strong team 176.0.0.0 192.0.0.0 192.0.0.1 192.0.0.2 192.0.0.3

## Примечания:

* Если пользователь team ранее не подключался к другим нодам, необходимо подтвердить подключение вводом "yes" (для пользователя hadoop не требуется)
* В ходе выполнения скрипта необходимо вводить соответствующие данные (пароль, пароль hadoop) (примечание: исправлял ошибку из-за неправильной работы adduser, не успел вернуть полную автоматизацию)
* В конце выполнения скрипта требуется подтвердить форматирование dfs, введя "Y"


# Инструкция по развётрыванию кластера hadoop без скрипта:
Обозначения:
* $USER - имя пользователя с правами root (team)
* $JN_IP - глобальный IP-адрес JN
* $JN_LIP - локальный  IP-адрес JN
* $NN_LIP - локальный  IP-адрес NN
* $DN0_LIP - локальный  IP-адрес DN-00
* $DN1_LIP - локальный  IP-адрес DN-01

1) Подключиться к edge-ноде по ssh: ssh $USER@$JN_IP
2) Сгенерировать ключ ssh для перемащения между нобами без пароля: ssh-keygen
3) Добавить его в авторизованные ключи: cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
4) Перенести shh ключ (папку .ssh) на другие ноды, для каждой: scp -r .ssh $USER@$NODE_IP:/home/$USER
5) На каждой ноде (включая JN), подключаясь по локальным IP аналогично пункту 1:

    5.1) Внести в файл /etc/hosts следующий текст, а остальные строки закомментировать: 
    
        $JN_LIP jn
        $NN_LIP nn
        $DN0_LIP dn-00
        $DN1_LIP dn-01

    5.2) Заменить текст в /etc/hostname на название сооветствующей ноды (jn, nn, dn-00, dn-01)

    5.3) Создать пользователя hadoop с надёжным паролем: sudo adduser hadoop

6) На JN подключиться к пользователю hadoop: sudo -i -u hadoop
7) Аналогично пунктам 2-4 сгенерировать и скаопировать 
8) Скачать архив с hadoop: wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
9) Скопировать его на другие ноды: scp hadoop-3.4.0.tar.gz NODE_NAME:/home/hadoop (NODE_NAME /in {nn, dn-00, dn-01})
10) На каждой ноде (аналогично подключение по ssh, но уже можно по именам из, например, пункта 9: ssh nn):

    10.1) Проверить наличие java соответствующей версии (8 или 11) для hadoop и установить при отсутствии

    10.2) Узнать директорию, в которой установлена java (обозначим $JAVA_HOME):

        10.2.1) Узнать symlink (обозначим $symlink): which java
        10.2.2) Узнать настоящий путь: readlink -f $symlink
        10.2.3) Скопировать домашнююдиректорию (на 2 каталога выше), например: /usr/lib/jvm/java-11-openjdk-amd64

    10.3) Добавить в конец файла .profile следующие строки (для инициализации переменных окружения):

        export HADOOP_HOME=/home/hadoop/hadoop-3.4.0
        export JAVA_HOME=$JAVA_HOME
        export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
    10.4) Применить изменения переменных: source .profile

    10.5) Добавить в конец файла hadoop-3.4.0/etc/hadoop/hadoop-env.sh строку export JAVA_HOME=$JAVA_HOME или в указанном месте (с закомментированной переменной JAVA_HOME) соответственно JAVA_HOME=$JAVA_HOME

    10.6) В файле hadoop-3.4.0/etc/hadoop/core-site.xml добавить конфигурацию:

        <configuration>
            <property>
                <name>
                    fs.defaultFS
                </name>
                <value>
                    hdfs://nn:9000
                </value>
            </property>
        </configuration>
    10.7) В файле hadoop-3.4.0/etc/hadoop/hdfs-site.xml добавить конфигурацию:

        <configuration>
            <property>
                <name>
                    dfs.replication
                </name>
                <value>
                    3
                </value>
            </property>
        </configuration>
    10.8) Добавить в файл hadoop-3.4.0/etc/hadoop/workers имена датанод:

        nn
        dn-00
        dn-01
11) Зайти на nn под пользователем hadoop
12) Отформатировать namenode: hadoop-3.4.0/bin/hdfs namenode -format
13) Запустить распределённую файловую систему: hadoop-3.4.0/sbin/start-dfs.sh
14) Для java 11 на каждой ноде проверить запущенные процессы: jps (пользователь hadoop)
15) Просмотреть логи на каждой ноде: ls hadoop-3.4.0/logs и cat соответствующего файла(ов) (пользователь hadoop)
