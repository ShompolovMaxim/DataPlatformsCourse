from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from onetl.connection import SparkHDFS
from onetl.connection import Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter

spark = SparkSession.builder \
		    .master("yarn") \
		    .appName("spark-with-yarn") \
		    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
		    .config("spark.hive.metastore.uris", "thrift://jn:9083") \
		    .enableHiveSupport() \
		    .getOrCreate()

print('Have connected to spark session! (task 1)')

# Task 2
hdfs = SparkHDFS(host="nn", port=9000, spark=spark, cluster="test")

try:
	hdfs.check()
	print('Have connected to HDFS claster! (task 2)')
except:
	print('Failed to connect to HDFS claster! (task 2)')

# Task 3
reader = FileDFReader(connection=hdfs, format=CSV(sep=",", header=True), source_path="/input")
df = reader.run(['ds.csv'])

# Task 4
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

# Tasks 5 and 6
hive = Hive(spark=spark, cluster="test")
writer = DBWriter(connection=hive, table="test.partitioned_data", options={"if_exists": "replace_entire_table", "partition_by": "Max_University_GPA"})
writer.run(new_df)
