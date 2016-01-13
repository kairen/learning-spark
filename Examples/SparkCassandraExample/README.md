# Spark tutorial for imac
本項目將儲存所有於分享會以及課程上，所接觸的系統建置、Spark API撰寫、HDFS 操作...等教學與整理，主要授課人員為 NUTC imac 內部團隊自我訓練。

### 主要包含項目
1. Spark 概念整理
2. Spark 環境部署模式
3. Spark API 簡單操作
4. Spark SQL API(Hive on Spark)
5. Spark Streaming API(DStream)
6. Message Queue Broker(such as MQTT, Kafka...etc)
7. Spark MLlib
8. ELK logs 分析
9. Spark 串接 s3 與 swift
10. Spark NoSQL 串接
11. Spark Dataframe

> 以上內容我們會逐一整理，並寫成文件來分享給大家。

### 參與貢獻
任何團隊成員都可以對該 git 做貢獻，未來也會請大家針對不一樣的作業進行提交，一個基本的貢獻流程如下所示：

1. 在 ```Github``` 上 ```fork``` 到自己的 Repository，例如：```<User>/Spark-tutorial.git```，然後 ```clone```到 local 端，並設定 Git 使用者資訊。

 ```sh
git clone https://github.com/imac-cloud/Spark-tutorial.git
cd spark-tutorial
git config user.name "User"
git config user.email user@email.com
```
2. 修改程式碼或頁面後，透過 ```commit``` 來提交到自己的 Repository：

 ```sh
git commit -am "Fix issue #1: change helo to hello"
git push
```
> 若新增採用一般文字訊息，如```Add Spark MLlib example ...```。

3. 在 GitHub 上提交一個 Pull Request。
4. 持續的針對 Project Repository 進行更新內容：

 ```sh
 git remote add upstream  https://github.com/imac-cloud/Spark-tutorial.git
 git fetch upstream
 git checkout master
 git rebase upstream/master
 git push -f origin master
 ```
