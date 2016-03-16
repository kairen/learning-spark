#SparkAlluxia


本範例利用Apach Spark針對 Aluxion 記憶體虛擬分散式儲存系統進行存取
>Aluxion 是一個記憶體虛擬分散式儲存系統，具有高效能、高容錯以及高可靠性的特色，它能夠統一資料的存取去串接機算框架和儲存系統的橋梁，像是同時可相容於Hadoop MapReduce和Apache Spark 以及 Apache Flink的計算框架和Alibaba OSS、Amazon S3、OpenStack Swift,、GlusterFS及 Ceph的儲存系統


## Alluxio

* 新增目錄

```
./bin/alluxio fs mkdir <path>
```
* 查看目錄

```
./bin/alluxio fs ls <path>
```

* 刪除

```
./bin/alluxio fs rm -R <path>
```

* 上傳

```
./bin/alluxio fs copyFromLocal <src> <remoteDst>
```
* 
新增檔案內容

```
./bin/alluxio fs touch <path>
```
* 
觀看檔案內容

```
./bin/alluxio fs cat <path>
```



## Apache Spark

參數配置

```
Configuration conf = sc.hadoopConfiguration();
conf.set("fs.alluxio.impl", "alluxio.hadoop.FileSystem");
```

讀取/存入

```
//alluxio://localhost:19998/imac
JavaRDD<String> rawRDD = sc.textFile(args[0]);
//alluxio://localhost:19998/imac
rawRDD.saveAsTextFile(args[1]);
```
	



