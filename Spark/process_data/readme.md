# Инструкция к скрипту:

## Для запуска загрузки, обработки данных, сохранения результатов с использованием Apache Spark и чтения данных стандартным клиентом hive необходимо запустить скрипт `run.sh` со следующими параметрами (слева указаны порядковые номера):

1) Пароль для пользователя hadoop
2) Глобальный IP-адрес JN

## Пример запуска скрипта:

`sh run.sh password_hadoop_strong 176.0.0.1`

## Примечания:

* На кластере предварительно должен быть развёрнуты Hadoop, YARN, Hive и Spark, а также подготовлена виртуальная среда python, например, способами, описанными в директориях Hadoop, Yarn, Hive и Spark этого репозитория соответственно
* На машине, на которой запускаются скрипты должен быть установлен sshpass
* Пароли должны передаваться в виде, воспринимаемом bash, то есть, например, знаки $ должны быть экранированы

# Инструкция по загрузке, обработке данных, сохранению результатов с использованием Apache Spark и чтению данных стандартным клиентом hive:

## Используемые обозначения:

* `$DATA` - имя файла с данными
* `$JN_IP` - глобальный IP-адрес JN
* `$TABLE` - имя таблицы для сохранения данных c указанием наименования базы данных, например `mydb.mytable`

## Действия с указанием пунктов домашнего задания в действии, в котором завершается выполнение данного пункта:

1) Предварительно загрузить на кластер файл с данными: `scp $DATA hadoop@$JN_IP:/home/hadoop`

2) Подключиться к edge-ноде по ssh: `ssh hadoop@$JN_IP`

3) Создать на HDFS директорию для загрузки данных /input, если она не была создана ранее: `hdfs dfs -mkdir -p input /`

4) Загрузить данные на HDFS: `hdfs dfs -put $DATA /input`

5) Создать виртуальное окружение: `python3 -m venv venv`

6) Активировать виртуальное окружение: `source venv/bin/activate`

7) Подключиться к виртуальной среде: `ipython`

8) Подключить необходимые зависимости:

        from pyspark.sql import SparkSession
        from pyspark.sql import functions as F
        from onetl.connection import SparkHDFS
        from onetl.connection import Hive
        from onetl.file import FileDFReader
        from onetl.file.format import CSV
        from onetl.db import DBWriter

9) Создать spark-сессию (пункт 1):

        spark = SparkSession.builder \
                            .master("yarn") \
                            .appName("spark-with-yarn") \
                            .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
                            .config("spark.hive.metastore.uris", "thrift://jn:9083") \
                            .enableHiveSupport() \
                            .getOrCreate()

10) Создать подключение к HDFS (пункт 2):

        hdfs = SparkHDFS(host="nn", port=9000, spark=spark, cluster="test")

11) Проверить подключение к HDFS: `hdfs.check()`

12) Создать читателя для CSV с необходимым разделителем (`sep`), например, для запятой: 

        reader = FileDFReader(connection=hdfs, format=CSV(sep=",", header=True), source_path="/input")

13) Прочитать наш файл (пункт 3): `df = reader.run(['$DATA'])`

14) Выполнить действия по изменению типов, например, для приведённого в данной директории датасета - изменить тип столбцов `Age` и `Work_Life_Balance` на int, а `University_GPA` - на float:

        df = df.withColumn("Age", df["Age"].cast("integer"))
        df = df.withColumn("Work_Life_Balance", df["Work_Life_Balance"].cast("integer"))
        df = df.withColumn("University_GPA", df["University_GPA"].cast("float"))

15) Выполнить трансформацию данных, например, для приведённого датасета выполнить агрегацию по столюцу `Field_of_Study` и посчитать функции агрегации от столбцов `Age`, `University_GPA` и `Work_Life_Balance` (пункт 4):

        new_df = df.groupBy("Field_of_Study").agg(
            F.count("Age").alias("Number_of_records"),
            F.max("University_GPA").alias("Max_University_GPA"),
            F.min("University_GPA").alias("Min_University_GPA"),
            F.avg("University_GPA").alias("Avg_University_GPA"),
            F.avg("Work_Life_Balance").alias("Avg_Work_Life_Balance"),
        )

16) Создать подключение к Hive: `hive = Hive(spark=spark, cluster="test")`

17) Проверить подключение к Hive: `hive.check()`

18) Создать писателя с данным подключением в партиционированную по `Max_University_GPA` таблицу (пункт 5):

        writer = DBWriter(connection=hive, table="$TABLE", options={"if_exists": "replace_entire_table", "partition_by": "Max_University_GPA"})

19) Выполнить запись трансформарованного датасета (пункт 6): `writer.run(new_df)`

20) Отключиться от ipython комбинацией клавиш `Ctlr + Z`

21) Подключиться к стандартному клиенту Hive `beeline -u jdbc:hive2://jn:5433 -n scott -p tiger`

22) Прочитать записанные данные (пункт 7): `select * from $TABLE limit 10;`
