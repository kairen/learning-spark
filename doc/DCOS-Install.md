# DC/OS 安裝
本篇說明如何透過 UI 與 CLI 進行安裝 DC/OS。

- [節點配置](#節點配置)
- [安裝前準備](#安裝前準備)
- [安裝 Bootstrap Node](#安裝-bootstrap-node)
  - [GUI 安裝](#gui-安裝)
  - [CLI 安裝](#cli-安裝)

## 節點配置
DC/OS 最低需求要四台主機，以下為本次安裝的硬體設備：

| Role       	| RAM         	| Disk            	| CPUs       	| IP Address 	|
|------------	|-------------	|-----------------	|------------	|------------	|
| bootstrap 	| 16 GB 記憶體 	| 250 GB 儲存空間 	| 四核處理器 	| 10.0.0.101 	|
| master    	| 8 GB 記憶體 	| 250 GB 儲存空間 	| 四核處理器 	| 10.0.0.102 	|
| agent-1    	| 8 GB 記憶體 	| 250 GB 儲存空間 	| 四核處理器 	| 10.0.0.103 	|
| agent-2    	| 8 GB 記憶體 	| 250 GB 儲存空間 	| 四核處理器 	| 10.0.0.104 	|

請以上節點都分別安裝 RHEL 或者 CentOS 作業系統。並且設定 IP 為靜態固定，編輯```/etc/sysconfig/network-scripts/ifcfg-<name>```檔案，加入以下內容：
```sh
ONBOOT="yes"
IPADDR="10.0.0.104"
PREFIX="24"
GATEWAY="10.0.0.1"
DNS1="8.8.8.8"
DNS2="8.8.8.4"
```

## 安裝前準備
在開始安裝以前，首先需要在每一台節點將基本環境的軟體更新：
```sh
$ sudo yum upgrade -y
```
> 完成後檢查是否是最新版本，可以透過以下方式查看 Kernel：
```sh
$ uname -r
3.10.0-327.13.1.el7.x86_64
```

> 如果不是以上版本，請執行以下指令：
```sh
$ sudo yum upgrade --assumeyes --tolerant
$ sudo yum update --assumeyes
```

由於在 CentOS 與 RHEL 預設會開啟防火牆，故要關閉防火牆與開機時自動啟動：
```sh
$ sudo systemctl stop firewalld && sudo systemctl disable firewalld
```

接著安裝一些基本工具軟體：
```sh
$ sudo yum install -y tar xz unzip curl ipset vim
```

設定啟動 OverlayFS :
```sh
$ sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF
```

設定關閉 SELinux 與設定一些資訊，並重新啟動：
```sh
$ sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config &&
sudo groupadd nogroup &&
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 &&
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 &&
sudo reboot
```

完成重新啟動後，在每一台節點安裝 Docker，首先要取得 Repos，設定以下來讓 yum 可以抓取：
```sh
$ sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

設定 systemd 執行 Docker daemon 於 OverlayFS：
```sh
$ sudo mkdir -p /etc/systemd/system/docker.service.d && sudo tee /etc/systemd/system/docker.service.d/override.conf <<- EOF
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon --storage-driver=overlay -H fd://
EOF
```

安裝 Docker engine，並啟動 docker 與設定開機啟動：
```sh
$ sudo yum install --assumeyes --tolerant docker-engine
$ sudo systemctl start docker
$ sudo systemctl enable docker
```
> 這邊可以設定使用者加入 docker 群組：
```sh
$ sudo gpasswd -a $(whoami) docker
```

## 安裝 Bootstrap Node
Bootstrap 節點主要提供佈署的功能，可以採用 UI 或 CLI 來進行部署，以下將說明如何透過建置 Bootstrap 來完成 DC/OS 佈署。

### GUI 安裝
這邊採用 GUI 方式來佈署 DC/OS，首先下載 [DC/OS installer](https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh?_ga=1.252969481.1283195233.1461920094)：
```sh
$ wget https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh
```

接著執行啟動 DC/OS UI：
```sh
$ sudo bash dcos_generate_config.sh --web -v
```

完成後，即可開啟瀏覽器輸入 [bootstrap web](http://<bootstrap-node-public-ip>:9000)

這邊需要輸入 Bootstrap 節點的 SSH 私有金鑰，透過以下方式產生與印出：
```sh
$ ssh-keygen -t rsa
$ cat .ssh/id_rsa
```

並建立一個腳本檔案```ip-dectect```，並加入以下內容：
```sh
#!/bin/bash
set -o nounset -o errexit

IP=<MASTER_IP>

echo $(ip route get ${IP} | awk '{print $NF; exit}')
```

上傳以上資訊，並填入 Master 與 Agent 的 IP Address。

### CLI 安裝
DC/OS 除了可以透過 GUI 進行安裝，也可以透過 CLI 的方式來佈署，首先建立目錄```genconf```：
```sh
$ mkdir -p genconf
$ cd genconf
```

然後建立一個腳本檔案```ip-dectect```，並加入以下內容：
```sh
#!/bin/bash
set -o nounset -o errexit

IP=<MASTER_IP>

echo $(ip route get ${IP} | awk '{print $NF; exit}')
```
> ```MASTER_IP```為修改成主節點 IP。


接著建立設定檔```config.yaml```，並加入以下內容：
```sh
---
agent_list:
- <agent-private-ip-1>
- <agent-private-ip-2>
bootstrap_url: file:///opt/dcos_install_tmp
cluster_name: "DC/OS Cluster"
master_discovery: static
master_list:
- <master-private-ip-1>
resolvers:
- 8.8.4.4
- 8.8.8.8
ssh_port: 22
ssh_user: <username>
```
> ```<agent-private-ip-1>``` 修改成 ```10.0.0.103```。

> ```<agent-private-ip-2>``` 修改成 ```10.0.0.104```。

> ```<master-private-ip-1>``` 修改成 ```10.0.0.102```。

> ```<username>``` 修改成 ```cloud-user```。P.S 這邊是用 cloud image。

完成後複製 Bootstrap 節點的 SSH 私有金鑰到目錄底下：
```sh
$ cp <path-to-key> genconf/ssh_key && chmod 0600 genconf/ssh_key
```

然後下載 DC/OS installer 來進行安裝，並且查看所有指令：
```sh
$ wget https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh
$ sudo bash dcos_generate_config.sh --help
```

透過 DC/OS installer 產生設定檔：
```sh
$ sudo bash dcos_generate_config.sh --genconf
Extracting image from this script and loading into docker daemon, this step can take a few minutes
dcos-genconf.e060aa49ac4ab62d5e-1e14856f55e5d5d07b.tar
Running mesosphere/dcos-genconf docker with BUILD_DIR set to /home/centos/genconf
====> EXECUTING CONFIGURATION GENERATION
...
```

成功的話目錄結構會類似以下：
```
├── dcos-genconf.<HASH>.tar
├── dcos_generate_config.sh
├── genconf
│   ├── config.yaml
│   ├── ip-detect
│   ├── cluster_packages.json
│   ├── serve
│   ├── ssh_key
│   ├── state
```

若沒問題就可以 prerequisites 佈署階段：
```sh
$ sudo bash dcos_generate_config.sh --install-prereqs
Running mesosphere/dcos-genconf docker with BUILD_DIR set to /home/centos/genconf
====> dcos_installer.action_lib.prettyprint:: ====> EXECUTING INSTALL PREREQUISITES
====> dcos_installer.action_lib.prettyprint:: ====> START install_prereqs
```

若沒問題就可以執行 preflight 來驗證叢集是否可以安裝：
```sh
$ sudo bash dcos_generate_config.sh --preflight
Running mesosphere/dcos-genconf docker with BUILD_DIR set to /home/centos/genconf
====> dcos_installer.action_lib.prettyprint:: ====> EXECUTING PREFLIGHT
====> dcos_installer.action_lib.prettyprint:: ====> START run_preflight
====> dcos_installer.action_lib.prettyprint:: ====> STAGE preflight
```

一樣若沒問題就可以執行 deploy 來安裝 DC/OS：
```sh
$ sudo bash dcos_generate_config.sh --deploy
Running mesosphere/dcos-genconf docker with BUILD_DIR set to /home/centos/genconf
====> dcos_installer.action_lib.prettyprint:: ====> EXECUTING DC/OS INSTALLATION
====> dcos_installer.action_lib.prettyprint:: ====> START deploy_master
```

最後沒問題就可以執行 postflight 來確認服務是否有啟動：
```sh
$ sudo bash dcos_generate_config.sh --postflight
Running mesosphere/dcos-genconf docker with BUILD_DIR set to /home/centos/genconf
====> dcos_installer.action_lib.prettyprint:: ====> EXECUTING POSTFLIGHT
====> dcos_installer.action_lib.prettyprint:: ====> START run_postflight
```

都完成後就可以查看 [Zookpeer](http://<master-public-ip>:8181/exhibitor/v1/ui/index.html) 與 [DC/OS](http://<public-master-ip>/)。
