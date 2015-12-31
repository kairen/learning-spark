# Hadoop YARN Installer 
Using shell script to install Hadoop YARN and DFS cluster.


## 快速開始
### 事前準備
首先我們要在各節點先安裝 ssh-server ，並配置需要的相關環境：
```sh
$ sudo apt-get install openssh-server
```
設定(user)不用需打 sudo 密碼：
```sh
$ echo "ubuntu ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ubuntu && sudo chmod 440 /etc/sudoers.d/ubuntu
```
建立ssh key，並複製 key 使之不用密碼登入：
```sh
$ ssh-keygen -t rsa
$ ssh-copy-id localhost
```
新增各節點 Hostname 至 /etc/hosts 檔案：
```sh
127.0.0.1 localhost

10.21.20.222 hadoop-master
10.21.20.216 hadoop-slave-1
10.21.20.249 hadoop-slave-2
10.21.20.207 hadoop-slave-3
```
並在 Master 或 Deploy 節點複製所有 Slave 的 ssh key：
```sh
$ ssh-copy-id ubuntu@hadoop-slave-1
$ ssh-copy-id ubuntu@hadoop-slave-2
```
> 若部署節點系統 ```User name``` 與 Hadoop 節點不同，請新增檔案```~/.ssh/config```，並加入以下內容：
>```sh
Host hadoop-master
    Hostname hadoop-master
    User ubuntu
Host hadoop-slave-1
    Hostname hadoop-slave-1
    User ubuntu
Host hadoop-slave-2
    Hostname hadoop-slave-2
    User ubuntu
```
> 當然也可以不要使用 Host Name，直接輸入 IP。

於 Master 或 Deploy 節點下載該腳本專案：
```sh
$ git clone https://github.com/imac-cloud/Spark-tutorial.git
```

### 腳本使用方式
進入 ```Spark-tutorial/scripts/hadoop-deploy/```目錄，並執行```./hadoop-deploy```腳本，若沒輸入任何參數會看到該腳本使用方式：
```sh
[Usage]
hadoop-deploy master-install {host1, host2, hosts}     # Install a master node and all-in-one hadoop node
              --spark {true}                           # Install spark to node, the default is false
              --version {2.6.0}                        # Install version, the default is 2.6.0

hadoop-deploy slave-install {host1, host2, hosts}      # Install some slaves node
              --master {master}                        # Add some master to slaves
              --version {2.6.0}                        # Install version, the default is 2.6.0
```

### 部署 Hadoop master
使用```master-install```來安裝 master 節點，範例如下：
```sh
$ ./hadoop-deploy master-install --spark true --version 2.6.0 10.21.20.222

Processing 10.21.20.222
Progress : [########--------------------------------] 20%  [INFO] Installing oracle java8 .....
Progress : [################------------------------] 40%  [INFO] Installing other packages .....
Progress : [########################----------------] 60%  [INFO] Automatically generated ssh keys .....
Progress : [################################--------] 80%  [INFO] Installing Hadoop .....
Progress : [####################################----] 92%  [INFO] Installing Spark ....
Progress : [########################################] 100%  [INFO] Install Finish ....
[INFO] Now, Using "/opt/hadoop-2.6.0/sbin/start-all.sh" to start service ...
```
> ```--spark```為是否要安裝 Spark，```--version```為 Hadoop 版本號。


### 部署 Slaves
使用```slave-install```來安裝 slaves 節點，範例如下：
```sh
$ /hadoop-deploy slave-install --master 10.21.20.222 10.21.20.216 10.21.20.249 10.21.20.207

Processing 10.21.20.216
Progress : [########--------------------------------] 20%  [INFO] Installing oracle java8 .....
Progress : [################------------------------] 40%  [INFO] Installing other packages .....
Progress : [########################----------------] 60%  [INFO] Automatically generated ssh keys .....
Progress : [################################--------] 80%  [INFO] Installing Hadoop .....
Progress : [########################################] 100%  [INFO] Install Finish ....
Processing 10.21.20.249
Progress : [########--------------------------------] ...
```
> ```--master```為主節點 IP or Hostname，```--version```為版本號。

### 驗證安裝
當上述動作都完成後，我們可以透過開啟 Hadoop 叢集來驗證系統安裝狀況：
```sh
$ /opt/hadoop-2.6.0/sbin/start-all.sh
Starting namenodes on [10-21-20-222.maas]
10-21-20-222.maas: starting namenode, logging to /opt/hadoop-2.6.0/logs/hadoop-ubuntu-namenode-hadoop-master.out
10.21.20.216: starting datanode, logging to /opt/hadoop-2.6.0/logs/hadoop-ubuntu-datanode-hadoo-slave-1.out
10.21.20.207: starting datanode, logging to /opt/hadoop-2.6.0/logs/hadoop-ubuntu-datanode-hadoop-slave-2.out
10.21.20.249: starting datanode, logging to /opt/hadoop-2.6.0/logs/hadoop-ubuntu-datanode-hadoop-slave-3.out
...
```
在 master 節點輸入```jps```：
```sh
$ jps
12244 Jps
11592 NameNode
11978 ResourceManager
11823 SecondaryNameNode
```
在 slaves 節點輸入```jps```：
```sh
$ ssh 10.21.20.207 jps
7515 DataNode
7837 Jps
7663 NodeManager
```