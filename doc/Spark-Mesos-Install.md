# Spark Mesos 
本教學為安裝 Spark Mesos 的叢集版本，將 Spark 應用程式執行於 Mesos 分散式機制與各台機器連結上，來讓應用程式執行於不同的工作節點上。

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
$ sudo apt-get -y install oracle-java8-installer
$ sudo apt-get install oracle-java8-set-default
```



新增各節點 Hostname 至 ```/etc/hosts``` 檔案：
```sh
127.0.0.1 localhost

192.168.1.10 mesos-master
192.168.1.11 mesos-slave-1
192.168.1.11 mesos-slave-2
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
$ sudo apt-get -y install mesos marathon
```
> Mesos 套件將自動的抓取 ZooKeeper 套件

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

### Verifying Installation
當安裝完成，我們要驗證系統是否正常運行，可以透過以下指令運行：
```sh
MASTER=$(mesos-resolve `cat /etc/mesos/zk`)
mesos-execute --master=$MASTER --name="cluster-test" --command="sleep 5"
```
> 若要查看細節資訊，可以用瀏覽器開啟 [Mesos Console](http://<master-ip>:5050)、[Marathon console](http://<master-ip>:8080) 