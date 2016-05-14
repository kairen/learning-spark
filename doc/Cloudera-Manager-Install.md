# Cloudera Manager Ubuntu安裝 (待修改與更新...)
### 部署準備
首先編輯```/etc/network/interfaces```，設定好每台電腦ip為靜態：
```txt
auto eth0
iface eth0 inet static
        address 10.21.20.xx
        netmask 255.255.255.0
        network 10.21.20.0
        broadcast 10.21.20.255
        gateway 10.21.20.254
        dns-nameservers 163.17.131.2
```
完成後，在主節點編輯```/etc/hosts```加入以下資訊：
```txt
10.21.20.225	master.hadoop.com master
10.21.20.229    slave0.hadoop.com slave0
10.21.20.211    slave1.hadoop.com slave1
10.21.20.208    slave2.hadoop.com slave2
10.21.20.232    slave3.hadoop.com slave3
10.21.20.218    slave4.hadoop.com slave4
```
然後透過```ssh-copy-id```複製金鑰到Manager節點：
```sh
ssh-copy-id slave0
ssh-copy-id slave1
...
```
將主節點的```/etc/hosts```複製到其他節點：
```sh
scp /etc/hosts slave0:/etc/
```
在每個節點設定Sudoer不需要密碼：
```sh
echo "hadoop ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/hadoop && sudo chmod 440 /etc/sudoers.d/hadoop
```
在每個節點安裝 Java 7 Jdk :
```sh
sudo apt-get purge openjdk*
sudo apt-get -y autoremove
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java7-installer
```

### 下載與執行安裝檔
在主節點上安裝 Cloudera Manager 套件:
```sh
wget http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin

chmod u+x cloudera-manager-installer.bin
sudo ./cloudera-manager-installer.bin
```
### 開始Logging
```sh
sudo tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log
```


# Uninstall
Server端可以透過以下指令刪除：
```sh
sudo /usr/share/cmf/uninstall-cloudera-manager.sh
sudo rm -Rf /usr/share/cmf /var/lib/cloudera* /var/cache/yum/cloudera*
sudo rm -rf /etc/cloudera-manager-server/
```

其他節點可以透過該script刪除：
```sh
#!/bin/bash

hosts=$(cat /etc/hosts | grep -o "slave\w*.hadoop.\w*")
IFS=$'
'
for host in $hosts; do
   ssh $host sudo rm -Rf /usr/share/cmf /var/lib/cloudera* /var/cache/yum/cloudera*
   ssh $host sudo /usr/sbin/service cloudera-scm-agent hard_stop
   ssh $host sudo apt-get purge 'cloudera-manager-*' -y
   ssh $host sudo apt-get autoremove -y
   ssh $host sudo apt-get clean
   ssh $host sudo rm -Rf /var/lib/flume-ng /var/lib/hadoop* /var/lib/hue /var/lib/oozie /var/lib/solr /var/lib/sqoop*
   ssh $host sudo rm -Rf /dfs /mapred /yarn
   ssh $host sudo reboot
done
```
> * [刪除其他Components](http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-0-0/CDH5-Installation-Guide/cdh5ig_cdh_comp_uninstall.html)
* [刪除 Server與Agent](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_ig_uninstall_cm.html)


# 參考
* [CDH Ubuntu](http://www.bogotobogo.com/Hadoop/BigData_hadoop_CDH5_Install.php)
* [CDH 官方文件](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html)
