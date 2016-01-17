#SparkMySQL

這是一個 Spark 與 MySQL 溝通進行儲存的範例


## MySQL

**install**

```
sudo apt-get update
sudo apt-get install -y mysql-server

```

**enter mysql**

```
mysql -u root -p
```

**select database**

```
use mysql;
```

**create table**


```
create table testData(name varchar(32) not null , value varchar(32) not null);
```

**show table content**
```
select * from testData;
```

##Spark

**System**

* Spark 1.5.2
* Ubuntu 14.04


**Libriary**

* mysql-connector-java-5.1.38-bin.jar


**Code**

* ip : 127.0.0.1
* database : mysql
* user : root
* password : mysql


```
mcConnect = DriverManager.getConnection("jdbc:mysql://127.0.0.1/mysql","root", "mysql");
```

* table : testData
* column1 : name
* column2 : value

```
mStatement = mcConnect.prepareStatement("insert into testData(name,value) values(?,?)");
```



* setString -> 1 => column1(name) ， v => column1's content 
* setString -> 1 => column1(value) ， "abcd" => column2's content 


```
mStatement.setString(1, v);
mStatement.setString(2, "abcd");
mStatement.executeUpdate();

```

**Result**

```
mysql> select * from testData;
+------+-------+
| name | value |
+------+-------+
| a    | abcd  |
| b    | abcd  |
+------+-------+
2 rows in set (0.00 sec)

```
