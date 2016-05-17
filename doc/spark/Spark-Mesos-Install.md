# Spark Mesos
Mesos 叢集是由多個主節點與工作節點組合而成，它實作了兩層的排程（Scheduler）來提供粗/細粒度的排程。在 Mesos 中主節點（Master）主要負責資料的分配與排程，然而從節點（Slave）則是主要執行任務負載的角色。Mesos 也提供了高可靠的部署模式，可利用多個主節點的 ZooKeeper 來做服務發現。

![](images/mesos.png)


在 Mesos 上所執行的應用程式都被稱為```框架（Framework）```，該框架會被 Mesos 以 API 方式處理資源的提供，並將任務提交給 Mesos。其任務執行流程有以下幾個步驟構成：

* Slave 提供可用資源給 Master
* Master 向 Framework 的資源供應，並說明 Slave 資源
* Framework Scheduler 回應任務以及每個任務的資源需求
* Master 將任務發送到適當的 Slave 執行器（Executor）

![](images/mesos-framework-example.jpg)

## 事前準備
以下為節點配置：

| IP Address  |   HostName   |
|-------------|--------------|
|192.168.1.10 | mesos-master |
|192.168.1.11 | mesos-slave-1|
|192.168.1.12 | mesos-slave-2|

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

安裝Java 1.8 JDK：
```sh
$ sudo apt-get purge openjdk*
$ sudo apt-get -y autoremove
$ sudo apt-get install -y software-properties-common
$ sudo add-apt-repository -y ppa:webupd8team/java
$ sudo apt-get update
$ echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
$ echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
$ sudo apt-get -y install oracle-java8-installer
```

新增各節點 Hostname 至 ```/etc/hosts``` 檔案：
```sh
127.0.0.1 localhost

192.168.1.10 mesos-master
192.168.1.11 mesos-slave-1
192.168.1.12 mesos-slave-2
```

並在```Master```節點複製所有```Slave```的 ssh key：
```sh
$ ssh-copy-id ubuntu@mesos-slave-1
$ ssh-copy-id ubuntu@mesos-slave-2
```

## Mesos 安裝
首先要安裝 Mesos 於系統上，可以採用以下方式獲取最新版本的 Respository：
```sh
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
$ DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
$ CODENAME=$(lsb_release -cs)
$ echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
```
加入 key 與 repository 後，即可透過```apt-get```安裝：
```sh
$ sudo apt-get update
$ sudo apt-get -y install mesos
```
> ```P.S```： Master 需要再安裝 marathon

> Mesos 套件將自動的安裝 ZooKeeper 套件

### Master 節點配置
設定 Zookeeper ID：
```sh
echo 1 | sudo tee /etc/zookeeper/conf/myid
```
設定 Zookeeper configuration
```sh
HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
echo server.1=$HOST_IP:2888:3888 | sudo tee -a /etc/zookeeper/conf/zoo.cfg
```
> 若要部署 HA 需要加入多個 Master 節點的 Zookeeper。

啟動 Zookeeper 服務：
```sh
sudo service zookeeper restart
```
接著設定 Mesos zk configuration：
```sh
echo zk://$HOST_IP:2181/mesos | sudo tee /etc/mesos/zk
```
設定 Mesos quorum 參數：
```sh
echo 1 | sudo tee /etc/mesos-master/quorum
```
> 若是 OpenStack VM 需要再設定 Host IP 為 Float IP：（Optional）
```sh
EXENTAL_IP='10.26.1.69'
echo $EXENTAL_IP | sudo tee /etc/mesos-master/hostname
echo $HOST_IP | sudo tee /etc/mesos-master/ip
echo 'mesos-cluster' | sudo tee /etc/mesos-master/cluster
```

接著設定 ```advertise_ip```：
```sh
echo $HOST_IP | sudo tee /etc/mesos-master/advertise_ip
```

當設定完成，要接著設定 Marathon，首先建立組態目錄：
```sh
sudo mkdir /etc/marathon/
sudo mkdir /etc/marathon/conf
```

設定 ```hostname```：
```
echo $EXENTAL_IP | sudo tee /etc/marathon/conf/hostname
```

設定 master ip ：
```sh
echo zk://$HOST_IP:2181/mesos | sudo tee /etc/marathon/conf/master
```

設定 master zookeeper ：
```sh
echo zk://$HOST_IP:2181/marathon | sudo tee /etc/marathon/conf/zk
```

關閉 Master 節點的 ```mesos-slave``` service：
```sh
sudo service mesos-slave stop
sudo sh -c "echo manual > /etc/init/mesos-slave.override"
```

重新啟動 Mesos 與 Marathon 服務：
```sh
sudo service mesos-master restart
sudo service marathon restart
```

### Slave 節點配置
由於我們是使用 ubuntu 套件，Zookeeper 會以相依套件被自動下載至環境上，故我們要手動停止服務：
```sh
sudo service zookeeper stop
sudo sh -c "echo manual > /etc/init/zookeeper.override"
```
設定 Mesos 與 Marathon：
```sh
MASTER_IP="10.26.1.69"
PUBlIC_IP="10.26.1.80"
HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
echo zk://$MASTER_IP:2181/mesos | sudo tee /etc/mesos/zk
```
設定 Hostname 可以使用 OpenStack Float IP（Optional）：
```sh
echo $PUBlIC_IP | sudo tee /etc/mesos-slave/hostname
```

設定 slave ip：
```sh
echo $HOST_IP | sudo tee /etc/mesos-slave/ip
```
關閉 mesos-master 服務，並取消自動開機啟動：
```sh
sudo service mesos-master stop
sudo sh -c "echo manual > /etc/init/mesos-master.override"
```

重新啟動 Mesos slave 服務：
```sh
sudo service mesos-slave restart
```

### 驗證安裝結果
當安裝完成，我們要驗證系統是否正常運行，可以透過以下指令運行：
```sh
MASTER=$(mesos-resolve `cat /etc/mesos/zk`)
mesos-execute --master=$MASTER --name="cluster-test" --command="sleep 5"
```
> 若要查看細節資訊，可以用瀏覽器開啟 [Mesos Console](http://<master-ip>:5050)、[Marathon console](http://<master-ip>:8080)

## 安裝 Spark Driver
首先下載 Spark，並修改權限：
```sh
$ curl -s http://files.imaclouds.com/packages/spark/spark-1.5.2-bin-hadoop2.6.tgz | sudo tar -xz -C /opt/
$ sudo mv /opt/spark-1.5.2-bin-hadoop2.6 /opt/spark
$ sudo chown $USER:$USER -R /opt/spark
```

之後到```spark/conf```目錄，將```spark-env.sh.template```複製為```spark-env.sh```：
```sh
$ cp spark-env.sh.template spark-env.sh
```

在```spark-env.sh```這內容最下方增加這幾筆環境參數：
```sh
export MESOS_NATIVE_JAVA_LIBRARY="/usr/lib/libmesos.so"
export MASTER="mesos://192.168.1.10:5050"
export SPARK_EXECUTOR_URI="/opt/spark-1.5.2.tgz"

export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:jre/bin/java::")

export SPARK_LOCAL_IP=$(ifconfig eth0 | awk '/inet addr/{print substr($2,6)}')
export SPARK_LOCAL_HOSTNAME=$(ifconfig eth0 | awk '/inet addr/{print substr($2,6)}')
```
> 若是多個 Master 採用以下方式```mesos://zk://192.168.100.7:2181,192.168.100.8:2181,192.168.100.9:2181/mesos```。

接著下載一個新的```spark-1.5.2-bin-hadoop2.6.tgz```，並解壓縮：
```sh
$ cd ~/
$ wget http://files.imaclouds.com/packages/spark/spark-1.5.2-bin-hadoop2.6.tgz
$ tar -xvf spark-1.5.2-bin-hadoop2.6.tgz
$ sudo mv spark-1.5.2-bin-hadoop2.6 spark-1.5.2
$ sudo vim spark-1.5.2/conf/spark-env.sh
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so
export SPARK_EXECUTOR_URI="/opt/spark-1.5.2.tgz"
export MASTER=mesos://192.168.1.10:5050
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:jre/bin/java::")
```
完成後壓縮資料夾：
```sh
$ sudo tar -czvf spark-1.5.2.tgz spark-1.5.2/

```
並在```Master```節點複製到所有```Slave```：
```sh
$ scp spark-1.5.2.tgz mesos-slave-1:~/ && ssh mesos-slave-1 sudo mv ~/spark-1.5.2.tgz /opt
$ scp spark-1.5.2.tgz mesos-slave-2:~/ && ssh mesos-slave-2 sudo mv ~/spark-1.5.2.tgz /opt
$
```

設定使用者環境參數：
```sh
$ echo "export SPARK_HOME=/opt/spark" | sudo tee -a ~/.bashrc
$ echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a ~/.bashrc
```

執行```spark-shell```，來驗證 Spark 可否正常執行：
```sh
$ spark-shell --master mesos://192.168.1.34:5050
val data = 1 to 10000
val distData = sc.parallelize(data)
distData.filter(_< 10).collect()
```
或使用範例程式提交 Job：
```sh
$ spark-submit --class org.apache.spark.examples.SparkPi \
--master mesos://192.168.1.10:5050 \
--num-executors 1 \
--executor-memory 1g \
--executor-cores 1 \
lib/spark-examples*.jar \
1
```
