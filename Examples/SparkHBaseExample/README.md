#SparkHBase

這是一個 Spark 與 HBase 溝通進行存取的範例，其中包含了PUT、GET和DELETE



##HBase

| test                |
| --   | --  |   --   | 
|      | cf  |        | 
| row1 | a   | value1 |
 

* TABLE_NAME : test
* ROW_NAME : row1
* COLUMN_NAME : cf
* KEY : a
* VALUE : value1



### HBASE端

啟動HBase
```
./bin/hbase shell

```
新增資料表

```
create 'test', 'cf'
```
觀看資料表內容

```
scan 'test'
```

### SPARK端

系統

* Spark 1.5.2

* Ubuntu 14.04

* HBase 1.1.2

Library

* hbase-protocol-1.0.0-cdh5.5.1.jar 
* spark-examples-1.4.0-hadoop2.6.0.jar
* spark-hbase-0.0.2-clabs.jar




**JavaHBaseBulkPutExample**

```
List<String> list = new ArrayList<String>();
list.add("1," + columnFamily + ",a,1");
```

* ROW_NAME : 1
* COLUMN_NAME : columnFamily
* KEY : a
* VALUE : 1

執行

```
spark-submit --class com.imac.JavaHBaseBulkPutExample --master local[2] --jars hbase-protocol-1.0.0-cdh5.5.1.jar,spark-examples-1.4.0-hadoop2.6.0.jar,spark-hbase-0.0.2-clabs.jar SparkHBase.jar local test cf
```


**JavaHBaseBulkGETExample**

```
List<byte[]> list = new ArrayList<byte[]>();
list.add(Bytes.toBytes("1"));
```
* ROW_NAME : 1  (針對ROW_NAME來取得資料)

 
執行

```
spark-submit --class com.imac.JavaHBaseBulkGetExample --master local[2] --jars hbase-protocol-1.0.0-cdh5.5.1.jar,spark-examples-1.4.0-hadoop2.6.0.jar,spark-hbase-0.0.2-clabs.jar SparkHBase.jar local test
```

**JavaHBaseBulkDeleteExample**


```
List<byte[]> list = new ArrayList<byte[]>();
list.add(Bytes.toBytes("1"));
```
* ROW_NAME : 1  (針對ROW_NAME來刪除資料)

執行

```
spark-submit --class com.imac.JavaHBaseBulkDeleteExample --master local[2] --jars hbase-protocol-1.0.0-cdh5.5.1.jar,spark-examples-1.4.0-hadoop2.6.0.jar,spark-hbase-0.0.2-clabs.jar SparkHBase.jar local test
```

