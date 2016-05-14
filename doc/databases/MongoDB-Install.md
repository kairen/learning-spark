# Mongo Database (待修改與更新...)
MongoDB 是一種文件導向的資料庫系統，是由 10gen 團隊所發展 NoSQL（Not Only SQL） 資料庫，被廣泛應用在儲存非結構化資料的系統，尤其在巨量資料處理中受到許多青睞，許多巨量資料框架也紛紛支援了 MongoDB，諸如：Spark、Hadoop等。

## 安裝
首先新增 MongoDB 的資源庫金鑰與 URL，然後安裝 MongoDB 3.x 版本：
```sh
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
$ echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
$ sudo apt-get update
$ sudo apt-get install mongodb-org
```

接著編輯```/etc/mongodb.conf```，修改以下內容：
```
net:
   bindIp: <IP>
   port: 27017
```
> 也可以修改 ```port```。

完成後即可啟動服務
```sh
$ sudo service mongod start
```
