# Spark Standalone 
本教學為安裝 Spark Standalone 的叢集版本，將 Spark 應用程式執行於自己的分散式機制與各台機器連結上，來讓應用程式執行於不同的工作節點上。

## 事前準備
首先我們要在各節點先安裝 ssh-server 與 Java JDK，並配置需要的相關環境：
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

新增各節點 Hostname 至 ```/etc/hosts``` 檔案：
```sh
127.0.0.1 localhost

192.168.1.10 hadoop-master
192.168.1.11 hadoop-slave1
192.168.1.11 hadoop-slave2
```

並在```Master```節點複製所有```Slave```的 ssh key：
```sh
$ ssh-copy-id ubuntu@hadoop-slave1
$ ssh-copy-id ubuntu@hadoop-slave2
```
## 安裝 Spark
首先下載 Spark，並修改權限：
```sh
$ curl -s http://files.imaclouds.com/packages/hadoop-spark/spark-1.5.2-bin-hadoop2.6.tgz | sudo tar -xz -C /opt/
$ sudo mv /opt/spark-1.5.2-bin-hadoop2.6 /opt/spark
$ sudo chown $USER:$USER -R /opt/spark
```

之後到```spark/conf```目錄，將```spark-env.sh.template```複製為```spark-env.sh```：
```sh
$ cp spark-env.sh.template spark-env.sh
```
在```spark-env.sh```這內容最下方增加這幾筆環境參數：
```sh
export SPARK_MASTER_IP="hadoop-master"  
export SPARK_MASTER_PORT="7077"
export SPARK_MASTER_WEBUI_PORT="8090"   
```
> ```SPARK_MASTER_IP```為主節點（Master）的 IP。
> ```SPARK_MASTER_PORT```為主節點（Master）的 Port。
> ```SPARK_MASTER_WEBUI_PORT```為 WebUI 的 Port，預設為 8080。

接著複製```slaves.template```為```slaves```： 
```sh
$ cp slaves.template slaves
```

在最下方增加每台機器的 hostname：
```sh
hadoop-slave1
hadoop-slave2
```

完成後將設定檔複製給其他台機器： 
```sh
scp -r /opt/spark ubuntu@hadoop-slave1:/opt
scp -r /opt/spark ubuntu@hadoop-slave2:/opt
```

啟動 Spark ：
```sh
/opt/spark/sbin/start-all.sh
```
> 這樣 Spark 就啟動完成了，開啟 [Web UI](http://<ip>:8090) 來檢查狀態。

設定使用者環境參數：
```sh
$ echo "export SPARK_HOME=/opt/spark" | sudo tee -a ~/.bashrc
$ echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a ~/.bashrc
```

## 驗證系統
為了驗證 Spark 是否成功安裝，可以透過執行一個範例程式來看看結果，如下所示：
```sh
$ cd /opt/spark
$ spark-submit --class org.apache.spark.examples.SparkPi \
--master spark://hadoop-master:7077 \
--num-executors 1 \
--executor-memory 1g \
--executor-cores 1 \
lib/spark-examples*.jar \
1
```