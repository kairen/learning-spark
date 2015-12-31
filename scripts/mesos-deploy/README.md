# Mesos Installer 
本腳本為部署 Mesos 叢集使用，分別針對 Mesos-master 與 Mesos-slave 進行部署，用以提升部署大型叢集的效率。

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

192.168.1.10 mesos-master
192.168.1.11 mesos-slave-1
192.168.1.12 mesos-slave-2
```
並在 Master 節點複製所有Slave的 ssh key：
```sh
$ ssh-copy-id ubuntu@mesos-slave-1
$ ssh-copy-id ubuntu@mesos-slave-2
```
於 Master 節點下載該腳本專案：
```sh
$ git clone https://github.com/imac-cloud/Spark-tutorial.git
```

### 腳本使用方式
進入 ```Spark-tutorial/scripts/mesos-deploy/```目錄，並執行```./mesos-deploy```腳本，若沒輸入任何參數會看到該腳本使用方式：
```sh
[Usage]
mesos-deploy master-install {host1, host2, hosts}      # installing a master node

mesos-deploy slave-install {host1, host2, hosts}       # installing some slaves node
  Arguments: --masters {master1, master2, masters}     # add some masters to slaves
```

### 部署 Masters
使用```master-install```來安裝 masters 節點，範例如下：
```sh
$ ./mesos-deploy master-install 192.168.1.10

[ ---------------- 192.168.1.10 ---------------- ]
[INFO] Installing oracle java8 .....
[INFO] Installing apache mesos .....
[INFO] Configure to mesos-master env .....
[INFO] Finish install .....
```
> 完成後，即可查看細節資訊，使用瀏覽器開啟 [Mesos Console](http://<master-ip>:5050)、[Marathon console](http://<master-ip>:8080) 


### 部署 Slaves
使用```slave-install```來安裝 slaves 節點，範例如下：
```sh
$ ./mesos-deploy slave-install 192.168.1.11 192.168.1.12 --masters 192.168.1.10

[ ---------------- 192.168.1.11 ---------------- ]
[INFO] Installing oracle java8 .....
[INFO] Installing apache mesos .....
[INFO] Configure to mesos-slave env .....
[INFO] Finish install .....
```
> 目前部署必須輸入```--masters``` 參數來配置 Masters 節點，該參數可以為多個 Master 節點

### 驗證安裝
當安裝完成，我們要驗證系統是否正常運行，可以在```master```節點透過以下指令驗證：
```sh
MASTER=$(mesos-resolve `cat /etc/mesos/zk`)
mesos-execute --master=$MASTER --name="cluster-test" --command="sleep 5"
```