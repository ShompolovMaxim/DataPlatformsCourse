create table if not exists test.mytable (
    c1 string,
    c2 float,
    c3 float,
    c4 float,
    c5 float,
    c6 float,
    c7 float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';