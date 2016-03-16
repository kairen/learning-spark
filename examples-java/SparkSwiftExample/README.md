#Spark to Openstack Swift



#Dependency
[hadoop-openstack-2.6.0.jar](https://repository.cloudera.com/artifactory/repo/org/apache/hadoop/hadoop-openstack/2.6.0/hadoop-openstack-2.6.0.jar)

#Apache Spark

###使用hadoopConfig

>記得使用  sc.hadoopConfiguration(); ， 不能使用 SparkConf
```
JavaSparkContext sc =new JavaSparkContext();
Configuration conf = sc.hadoopConfiguration();
```


###參數設定
fs.swift.service.PROVIDER.auth.url ， PROVIDER 可任一命名，以下為 ```PROVIDER = test``` 的例子
>    
>    fs.swift.service.test.auth.url : Keystone 驗證 url
>    
>    fs.swift.service.test.tenant : Openstack上的 Project name
>    
>    fs.swift.service.test.username : Openstack登入的帳號
>    
>    fs.swift.service.test.password : Openstack登入的密碼
```
conf.set("fs.swift.impl", "org.apache.hadoop.fs.swift.snative.SwiftNativeFileSystem");
conf.set("fs.swift.service.test.auth.url", "http://127.0.0.1:5000/v2.0/tokens");
conf.set("fs.swift.service.test.auth.endpoint.prefix", "endpoints");
conf.set("fs.swift.service.test.http.port", "8080");
conf.set("fs.swift.service.test.region", "RegionOne");
conf.set("fs.swift.service.test.public", "true");
conf.set("fs.swift.service.test.tenant", "big-data");
conf.set("fs.swift.service.test.username", "admin");
conf.set("fs.swift.service.test.password", "admin");
```

###Swift讀取/存入設定
swift://CONTAINER.PROVIDER/PATH 
> 
> CONTAINER = testfile
> 
> PROVIDER = test
> 
> PATH = file
```
JavaRDD<String> rawRDD = sc.textFile(args[0]);
rawRDD.saveAsTextFile("swift://testfile.test/file/");
```


#Opensatack Swift

安裝可參考 [OpenStack 相關技術整理](https://kairen.gitbooks.io/openstack/content/swift/index.html)