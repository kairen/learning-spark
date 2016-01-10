# JavaNetworkWordCount

網路即時監控，針對 Netcat 9999 port 偵測


### 程式碼(JAVA)

```
//設定 Spark Master名稱、AppName名稱
SparkConf conf = new SparkConf().setMaster("local[2]").setAppName("NetworkWordCount");

//設定 Stream 每 1 秒 讀取 data server 資料
JavaStreamingContext jssc = new JavaStreamingContext(conf,Durations.seconds(1));

//透過 Socket TCP 的方式接收 data server 資料 ， 設定 HOST "localhost" 、PORT "9999"
JavaReceiverInputDStream<String> lines = jssc.socketTextStream("localhost", 9999);


//接收的資料，透過空白來做切割
//ex ,  A B C  ->  (A) (B) (C)
JavaDStream<String> words = lines .flatMap(new FlatMapFunction<String, String>() {
                  public Iterable<String> call(String x) {
                                                return Arrays.asList(x.split(" "));
                                        }
                                });

//將切割完的資料以 key value 的方式輸出
//ex , (A) (B) (C) -> (A,1) (B,1) (C,1)
JavaPairDStream<String, Integer> pairs = words  .mapToPair(new PairFunction<String, String, Integer>() {
                            public Tuple2<String, Integer> call(String s) {
                                                return new Tuple2<String, Integer>(s, 1);
                                        }
                                });

//最後以 key 為單位做統計
JavaPairDStream<String, Integer> wordCounts = pairs.reduceByKey(new Function2<Integer, Integer, Integer>() {
                           public Integer call(Integer i1, Integer i2) {
                                                return i1 + i2;
                                         }
                               });

 將結果印出來                                  
wordCounts.print();

開啟 Stream 運算
jssc.start(); // Start the computation
jssc.awaitTermination(); // Wait for the computation to terminate

```

###  NetCat(data server)

**Start**
```
nc -lk 9999

```


**Input**
```
hello world
hello spark
hello yurnom

```


**Result**
```
-------------------------------------------
Time: 1407741020000 ms
-------------------------------------------
(yurnom,1)
(hello,3)
(world,1)
(spark,1)

```



###  Write into HDFS
```
wordCounts.saveAsNewAPIHadoopFiles("/user/haoop/streaming", "hadoop" ,String.class , Integer.class , (Class<? extends OutputFormat<String, Integer>>) TextOutputFormat.class);

```





