# Hadoop YARN 單機安裝
本教學為安裝 Spark on Hadoop YARN 的 all-in-one 版本，將 Spark 應用程式執行於 YARN 上，來讓應用程式執行於不同的工作節點上。

## 事前準備
首先我們要先安裝 ssh-server 與 Java JDK，並配置需要的相關環境：
```sh
$ sudo apt-get install openssh-server
```

設定<user>(hadoop)不用需打 sudo 密碼：
```sh
$ echo "hadoop ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/hadoop && sudo chmod 440 /etc/sudoers.d/hadoop
```
> P.S 要注意 ```hadoop``` 要隨著現在使用的 User 變動。

建立ssh key，並複製 key 使之不用密碼登入：
```sh
$ ssh-keygen -t rsa
$ ssh-copy-id localhost
```

安裝Java 1.7 JDK：
```sh
$ sudo apt-get purge openjdk*
$ sudo apt-get -y autoremove
$ sudo add-apt-repository -y ppa:webupd8team/java
$ sudo apt-get update
$ echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
$ echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
$ sudo apt-get -y install oracle-java7-installer
```
## 安裝 Hadoop YARN 
首先我們須先將 Hadoop YARN 安裝完成，詳細步驟如下所示。
下載Hadoop 2.6.0 or laster version：
```sh
$ curl -s http://files.imaclouds.com/packages/hadoop/hadoop-2.6.0.tar.gz | sudo tar -xz -C /opt/

$ sudo mv /opt/hadoop-2.6.0 /opt/hadoop
```
> 若要下載不同版本可以到官方查看。

到hadoop底下的/etc/hadoop設定所有conf檔與```evn.sh```檔：
```sh
$ cd /opt/hadoop/etc/hadoop
$ sudo vim hadoop-env.sh
# 修改裡面的Java_Home
export JAVA_HOME=/usr/lib/jvm/java-7-oracle
```

修改```mapred-site.xml.template```檔案：
```sh
$ sudo mv mapred-site.xml.template mapred-site.xml
$ sudo vim mapred-site.xml

# 修改以下放置到<configuration></configuration>裡面
<property>
   <name>mapreduce.framework.name</name>
   <value>yarn</value>
</property>
```

修改```hdfs-site.xml```檔案：
```sh
$ sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode
$ sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode
$ sudo chown -R $USER_NAME:$USER_NAME /usr/local/hadoop_store
$ sudo vim hdfs-site.xml

# 修改以下放置到<configuration></configuration>裡面
<property>
   <name>dfs.replication</name>
   <value>1</value>
</property>
<property>
   <name>dfs.namenode.name.dir</name>
   <value>/usr/local/hadoop_store/hdfs/namenode</value>
</property>
<property>
   <name>dfs.datanode.data.dir</name>
   <value>/usr/local/hadoop_store/hdfs/datanode</value>
</property>
```

修改```core-site.xml```檔案：
```sh
$ sudo mkdir -p /app/hadoop/tmp
$ sudo chown $USER_NAME:$USER_NAME /app/hadoop/tmp
$ sudo vim core-site.xml

# 修改以下放置到<configuration></configuration>裡面
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/app/hadoop/tmp</value>
        <description>A base for other temporary directories.</description>
    </property>
```

修改```yarn-site.xml```檔案：
```sh
$ sudo vim yarn-site.xml

# 修改以下放置到<configuration></configuration>裡面
 <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
</property>
```

進行 Namenode 格式化：
```sh
$ cd /opt/hadoop/bin
$ ./hadoop namenode -format
```

沒出錯的話，就可以開啟Hadoop對應服務：
```sh
$ cd /opt/hadoop/sbin
$ ./start-yarn.sh
$ ./start-dfs.sh
```

檢查是否開啟以下服務：
```sh
$ jps
3457 ResourceManager
7087 Jps
3593 NodeManager
4190 DataNode
4025 NameNode
4383 SecondaryNameNode
```
> 開啟 [Website YARN Dashboard](http://localhost:8088) 與 [HDFS Dashboard](http://localhost:50070) 

設定環境變數：
```sh
$ cd
$ sudo vim .bashrc
# 加入以下到最後一行
export HADOOP_HOME="/opt/hadoop"
export PATH=PATH:$HADOOP_HOME
export HADOOP_BIN="/opt/hadoop/bin"
export PATH=$PATH:$HADOOP_BIN
```

透過 ```source``` 指令引用環境變數：
```sh
$ source .bashrc
```

### 驗證系統
為了驗證系統是否建置成功，可執行一個範例程式來看看是否能夠正常執行，如下所示：
首先上傳資料到HDFS上：
```sh
$ sudo vim words.txt

# 加入以下，可以自行在多加
AA
CD
BB
DE
AA
AA
# 加入以上

$ hadoop fs -mkdir /example
$ hadoop fs -put words.txt /example
```

執行範例程式：
```sh
$ cd /opt/hadoop/share/hadoop/mapreduce
$ hadoop jar hadoop-mapreduce-examples-2.6.0.jar wordcount /example/words.txt /example/output
```

## Spark 安裝
不管單機或叢集，安裝 Spark 只需要在 Master 節點上進行即可，步驟如下：

首先下載 Spark，並修改權限：
```sh
$ curl -s http://files.imaclouds.com/packages/hadoop-spark/spark-1.5.2-bin-hadoop2.6.tgz | sudo tar -xz -C /opt/
$ sudo mv /opt/spark-1.5.2-bin-hadoop2.6 /opt/spark
$ sudo chown $USER_NAME:$USER_NAME -R /opt/spark
```
> 其他 Hadoop 版本可以到這邊[Spark-Hadoop](http://d3kbcqa49mib13.cloudfront.net)查看。

設定 Spark 環境參數：
```sh
$ echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
$ echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
$ echo "export SPARK_HOME=/opt/spark" | sudo tee -a /opt/spark/conf/spark-env.sh
$ echo "export SPARK_JAR=/opt/spark/lib/spark-assembly-1.5.2-hadoop2.6.0.jar" | sudo tee -a /opt/spark/conf/spark-env.sh
$ echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a /opt/spark/conf/spark-env.sh
```

設定使用者環境參數：
```sh
$ echo "export SPARK_HOME=/opt/spark" | sudo tee -a ~/.bashrc
$ echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a ~/.bashrc
```

### 驗證系統
為了驗證 Spark 是否成功安裝，可以透過執行一個範例程式來看看結果，如下所示：
```sh
$ cd /opt/spark
$ spark-submit --class org.apache.spark.examples.SparkPi \
--master yarn-cluster \
--num-executors 1 \
--executor-memory 1g \
--executor-cores 1 \
lib/spark-examples*.jar \
1
```