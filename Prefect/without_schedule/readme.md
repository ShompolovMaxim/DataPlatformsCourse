# Инструкция к скрипту:

## Для запуска обработки данных в рамках потока с единоразовым выполнением необходимо запустить скрипт `run.sh` со следующими параметрами (слева указаны порядковые номера):

1) Пароль для пользователя hadoop
2) Глобальный IP-адрес JN

## Пример запуска скрипта:

`sh run.sh password_hadoop_strong 176.0.0.1`

## Примечания:

* На кластере предварительно должен быть развёрнуты Hadoop, YARN, Hive и Spark, а также подготовлена виртуальная среда python, например, способами, описанными в директориях Hadoop, Yarn, Hive и Spark этого репозитория соответственно
* В директорию /input HDFS должен быть загружен файл ds.csv, что было выполнено в директории Spark этого репозитория. Требуется конкретный датасет, который уже был загружен в предыдущих заданиях, так как преобразования данных в Spark, которые проводятся в скрипте, могут быть выполнены только над этим датасетом или датасетом с такой же схемой
* На машине, на которой запускаются скрипты должен быть установлен sshpass
* Пароли должны передаваться в виде, воспринимаемом bash, то есть, например, знаки $ должны быть экранированы

# Инструкция по обработке данных в рамках потока с единоразовым выполнением:

## Используемые обозначения:

* `$DATA` - имя файла с данными
* `$JN_IP` - глобальный IP-адрес JN
* `$TABLE` - имя таблицы для сохранения данных c указанием наименования базы данных, например `mydb.mytable`

## Действия (предполагается, что данные уже загружены в директорию HDFS /input, так как это уже рассматривалось в предыдущих домашних заданиях):

1) Подключиться к edge-ноде по ssh: `ssh hadoop@$JN_IP`

2) Создать виртуальное окружение: `python3 -m venv venv`

3) Активировать виртуальное окружение: `source venv/bin/activate`

4) Установить prefect: `pip install prefect`

5) Создать скрипт python для дальнейшего выполнения (в данной инструкции считается, что все действия выполняются в директории /home/hadoop и скрипт имеет имя flow.py) с следующим примерным содержимым:

    5.1) Подключить необходимые зависимости Spark

        from pyspark.sql import SparkSession
        from pyspark.sql import functions as F
        from onetl.connection import SparkHDFS
        from onetl.connection import Hive
        from onetl.file import FileDFReader
        from onetl.file.format import CSV
        from onetl.db import DBWriter

    5.2) Подключить необходимые зависимости Prefect

        from prefect import flow, task
        from prefect.cache_policies import NO_CACHE

    5.3) Задать необходимые задачи для загрузки, обработки и сохранения данных, например, следующим образом:

    5.3.1) Создание сессии Spark:

        @task(cache_policy=NO_CACHE)
        def get_spark():
            spark = SparkSession.builder \
                                .master("yarn") \
                                .appName("spark-with-yarn") \
                                .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
                                .config("spark.hive.metastore.uris", "thrift://jn:9083") \
                                .enableHiveSupport() \
                                .getOrCreate()
            return spark

    5.3.2) Завершение сессии Spark:

        @task(cache_policy=NO_CACHE)
        def stop_spark(spark):
            spark.stop()

    5.3.3) Загрузка данных:

        @task(cache_policy=NO_CACHE)
        def extract(spark):
            hdfs = SparkHDFS(host="nn", port=9000, spark=spark, cluster="test")
            reader = FileDFReader(connection=hdfs, format=CSV(sep=",", header=True), source_path="/input")
            df = reader.run(['$DATA'])
            return df

    5.3.4) Преобразование данных на примере датасета из директории Spark:

        @task(cache_policy=NO_CACHE)
        def transform(df):
            df = df.withColumn("Age", df["Age"].cast("integer"))
            df = df.withColumn("High_School_GPA", df["High_School_GPA"].cast("float"))
            df = df.withColumn("SAT_Score", df["SAT_Score"].cast("integer"))
            df = df.withColumn("University_Ranking", df["University_Ranking"].cast("integer"))
            df = df.withColumn("University_GPA", df["University_GPA"].cast("float"))
            df = df.withColumn("Internships_Completed", df["Internships_Completed"].cast("integer"))
            df = df.withColumn("Projects_Completed", df["Projects_Completed"].cast("integer"))
            df = df.withColumn("Certifications", df["Certifications"].cast("integer"))
            df = df.withColumn("Soft_Skills_Score", df["Soft_Skills_Score"].cast("integer"))
            df = df.withColumn("Networking_Score", df["Networking_Score"].cast("integer"))
            df = df.withColumn("Job_Offers", df["Job_Offers"].cast("integer"))
            df = df.withColumn("Starting_Salary", df["Starting_Salary"].cast("float"))
            df = df.withColumn("Career_Satisfaction", df["Career_Satisfaction"].cast("integer"))
            df = df.withColumn("Years_to_Promotion", df["Years_to_Promotion"].cast("integer"))
            df = df.withColumn("Work_Life_Balance", df["Work_Life_Balance"].cast("integer"))

            new_df = df.groupBy("Field_of_Study").agg(
                F.count("Age").alias("Number_of_records"),
                F.max("University_GPA").alias("Max_University_GPA"),
                F.min("University_GPA").alias("Min_University_GPA"),
                F.avg("University_GPA").alias("Avg_University_GPA"),
                F.avg("Work_Life_Balance").alias("Avg_Work_Life_Balance"),
            )
            
            return new_df

    5.3.5) Сохранение данных:

        @task(cache_policy=NO_CACHE)
        def load(spark, df):
            hive = Hive(spark=spark, cluster="test")
            writer = DBWriter(connection=hive, table="$TABLE", options={"if_exists": "replace_entire_table", "partition_by": "Max_University_GPA"})
            writer.run(df)

    Примечание: параметр cache_policy=NO_CACHE в аннотации @task необходим для того, чтобы избежать предупреждение о невозможности кэширования объектов Spark

    5.4) Объединить заданные задачи в потоке выполнения:

        @flow
        def process_data():
            spark = get_spark()
            df = extract(spark)
            df = transform(df)
            load(spark, df)
            stop_spark(spark)

    5.5) Выполнеить flow:

        if __name__ == '__main__':
	        process_data()
            
6) Запустить поток: `python3 flow.py`