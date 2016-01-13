#SparkCassandra

這是一個透過Spark來與Cassandra進行存取溝通的一個範例




## Spark


設定 Cassandra ip 

	   
```
SparkConf conf = new SparkConf();'
conf.set("spark.cassandra.connection.host", args[0]);
conf.setAppName("TestCassandra");

```
	
定義資料格式 Person
```
List<Person> people = Arrays.asList(Person.newInstance(1, "John"), Person.newInstance(2, "Anna"), Person.newInstance(3, "Andrew"));
```



寫入 Cassandra
```
javaFunctions(rdd).writerBuilder("test", "people",mapToRow(Person.class)).saveToCassandra();
```

```
 id | name
----+--------
  1 |   John
  2 |   Anna
  3 | Andrew
```

讀取 Cassandra
```
JavaRDD<String> cassandraRowsRDD = javaFunctions(sc).cassandraTable("test", "people").map(new Function<CassandraRow, String>() {
			public String call(CassandraRow cassandraRow) throws Exception {
				return cassandraRow.toString();
			}
		});
```
```
Data as CassandraRows:
CassandraRow{id: 1, name: John}
CassandraRow{id: 2, name: Anna}
CassandraRow{id: 3, name: Andrew}
```

搜尋 Cassandra 欄位 name 等於 Anna 的資料
```
JavaRDD<String> rdd3 = javaFunctions(sc).cassandraTable("test", "people", mapRowTo(Person.class)).where("name=?", "Anna").map(new Function<Person, String>() {
			@Override
			public String call(Person person) throws Exception {
				return person.toString();
			}
		});
```


```
Data filtered by the where clause (name='Anna'):
Person{id=2, name=Anna}
```

搜尋 Cassandra 的 id 欄位


```
JavaRDD<String> rdd4 = javaFunctions(sc).cassandraTable("test", "people").select("id").map(new Function<CassandraRow, String>() {
			@Override
			public String call(CassandraRow cassandraRow) throws Exception {
				return cassandraRow.toString();
			}
		});
```

```
Data with only 'id' column fetched:
CassandraRow{id: 1}
CassandraRow{id: 2}
CassandraRow{id: 3}
```



## Cassandra

* 進入

```
./bin/cqlsh localhost 
```

* create keypace

```
CREATE KEYSPACE test WITH replication = {'class':'SimpleStrategy', 'replication_factor': 1} ;
```

* create table

```
CREATE TABLE people ( id int , name text , PRIMARY KEY ((id),name));
```

* 
內容

```
SELECT * FROM people;

```