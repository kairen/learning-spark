#SparkMongoDB

這是一個 Spark 與 MongoDB 溝通進行儲存及讀取的範例


## MongoDB

**install**

```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo service mongod start
```

**Enter MongoDB**

```
mongo
```

**show database**
```
db
```

**select database**

```
use test

```



**create collection**

```
db.imac.insert({"abc":"123"})
```

**show collection list**
```
show collections

```

**show collection content**
```
db.imac.find()

```

**remove collection**
```
db.imac.remove({})

```


##Spark

**System**

* Spark 1.5.2
* Ubuntu 14.04
* mongoDB 3.2.1

**Libriary**

* mongo-hadoop-core-1.4.0.jar
* mongodb-driver-3.2.1.jar


**Code**

Read

* ip : localhost
* port : 27017
* database : test
* collection : imac


```
Configuration mongodbConfig = new Configuration();
mongodbConfig.set("mongo.job.input.format","com.mongodb.hadoop.MongoInputFormat");
mongodbConfig.set("mongo.input.uri","mongodb://localhost:27017/test.imac");
```


Write

* ip : localhost
* port : 27017
* database : test
* collection : collection

```
Configuration outputConfig = new Configuration();
outputConfig.set("mongo.output.uri","mongodb://localhost:27017/test.collection");

```

* 參數一無作用

```
documents.saveAsNewAPIHadoopFile(
    	    "file:///this-is-completely-unused",
    	    Object.class,
    	    BSONObject.class,
    	    MongoOutputFormat.class,
    	    outputConfig
    	);
```

**Run**

```
spark-submit --class com.imac.TestMongoDB --master local[2] --jars mongo-java-driver-3.1.0.jar,mongo-hadoop-core-1.4.0.jar SparkMongoDB.jar

```

**Result**

```
> db.imac.find()
{ "_id" : ObjectId("569da1b32921195351b4ccec"), "abc" : "123" }

```

```
> show collections
collection
imac
```

```
> db.collection.find()
{ "_id" : ObjectId("569da1b32921195351b4ccec"), "abc" : "123" }

```
