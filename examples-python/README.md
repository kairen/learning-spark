# Spark examples for Python
這邊將針對使用 Python 來進行 Spark 巨量資料處理的應用程式開發。




### 上傳檔案到 HDFS
Spark API Example 採用以下測試資料來完成操作，可以透過 vim 或 nano 新增：
```txt
$ vim test.txt
# test data
a,123,456,789,11344,2142,123
b,1234,124,1234,123,123
c,123,4123,5435,1231,5345
d,123,456,789,113,2142,143
e,123,446,789,14,2142,113
f,123,446,789,14,2142,1113,323
```
新增完成後，上傳至 HDFS 或者 OpenStack Swift 上，以下為 HDFS 範例：
```sh
$ hadoop fs -mkdir -p /spark/hw
$ hadoop fs -put test.txt /spark/hw
```