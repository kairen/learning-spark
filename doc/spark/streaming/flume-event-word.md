# Java Flume Event Word

 Flume 監控某個本地端檔案變化，當新增內容到檔案內，SparkStreaming 會接收並顯示新增訊息


###Java Code

```java
		if (args.length != 2) {
			System.err.println("Usage: FlumeTest <host> <port>");
			System.exit(1);
		}

		StreamingExamples.setStreamingLogLevels();

		String host = args[0];
		int port = Integer.parseInt(args[1]);

		//設定上下文且設定每秒接收訊息
		Duration batchInterval = new Duration(1000);
		SparkConf conf = new SparkConf().setAppName("JavaFlumeStreaming");
		JavaStreamingContext sc = new JavaStreamingContext(conf, batchInterval);

		//建立輸入串流，且加入定義內容:上下文、主機 ip、port
		JavaReceiverInputDStream<SparkFlumeEvent> dStream = FlumeUtils.createStream(sc, host, port);

		//印出輸出，讓 Stream 接收訊息
		dStream.cache();
		dStream.map(new Function<SparkFlumeEvent, String>() {

			@Override
			public String call(SparkFlumeEvent arg0) throws Exception {
				// TODO Auto-generated method stub
				return arg0.event().getBody().array().toString();
			}
		}).print();

		//開啟 Stream 運算
		sc.start();
		sc.awaitTermination();
```

### Flume configure

```sh
	# Name the components on this agent
	a1.sources = r1
	a1.sinks = k1
	a1.channels = c1

	# Describe/configure the source
	a1.sources.r1.type = exec
	a1.sources.r1.command=tail -F /var/flume/access.log

	# Describe the sink
	a1.sinks.k1.type = avro
	a1.sinks.k1.hostname = localhost
	a1.sinks.k1.port = 33333

	# Use a channel which buffers events in memory
	a1.channels.c1.type = memory
	a1.channels.c1.capacity = 1000
	a1.channels.c1.transactionCapacity = 100

	# Bind the source and sink to the channel
	a1.sources.r1.channels = c1
	a1.sinks.k1.channel = c1
```

> flume source 偵測 /var/flume/access.log 檔案變化

### 開啟服務
>Spark:
>
```sh
spark-submit --class com.imac.Main --master local[2] \
--jars spark-examples-1.5.2-hadoop2.6.0.jar \
FlumeStreaming.jar localhost 33333 \
```
>>1.--jars spark-examples-1.5.2-hadoop2.6.0.jar 此行表示執行任務須加入支援Jar

>>2.必須先啟動 Spark Streaming 任務，再啟動 Flume-ng，否則報錯

>Flume:
```sh
bin/flume-ng agent -c conf -f conf/example.conf -n a1 -Dflume.root.logger=INFO,console
```

**Input**
```
$ sudo vim /var/flume/access.log
```
在裡面寫入"HI"

**Result**

```
	-------------------------------------------
	Time: 1407741020000 ms
	-------------------------------------------

	{"headers": {}, "body": {"bytes": "HI"}}
```
