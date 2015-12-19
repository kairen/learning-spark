# Spark example and homework
imac spark 教學範例與作業程式碼。分別包含以下：
* Spark API Example
* 找出當月消費前20名商品
* Spark SQL Example
* Spark Streaming Example
* Spark MLlib Example

### 單機部署方式
部署一個單機的 Spark 有許多種方式，由於方便教學使用，我們採用在 OpenStack 上建立一個 Ubuntu 14.04(15.10)，並使用以下兩種方式：
* 直接部署於 Ubuntu 環境上：
```sh
$ wget http://files.imaclouds.com/scripts/hadoop-spark-installer.sh
$ chmod u+x hadoop-spark-installer.sh
$ ./hadoop-spark-installer.sh
```
> 依照 文字介面的 GUI 輸入即可，輸入完後不需要手動按任何鍵，等完成後透過 source 環境參數：
```sh
$ source .bashrc
$ hadoop version
Hadoop 2.6.0
Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r e3496499ecb8d220fba99dc5ed4c99c8f9e33bb1
Compiled by jenkins on 2014-11-13T21:10Z
Compiled with protoc 2.5.0
...
```

* 透過 Docker 提供 Spark On YARN：
```sh
$ curl http://files.imaclouds.com/scripts/docker_install.sh | sh
$ docker pull kairen/yarn-spark:1.5
$ docker run -d -p 8088:8088 -p 50070:50070 -h spark-master  \
-v <your_dir>:/root/spark-run/ \
--name yarn-spark kairen/yarn-spark:1.5 -d
```
> 詳細參考 [Docker Hub](https://hub.docker.com/r/kairen/yarn-spark/) 的 README.md

### API Example Dataset
Spark API Example 採用以下測試資料來完成操作，可以透過 vim 或 nano 新增：
```txt
$ vim test.txt
# test data
a,123,456,789,11344,2142,123
b,1234,124,1234,123,123
c,123,4123,5435,1231,5345
d,123,456,789,113,2142,143
e,123,446,789,14,2142,113
f,123,446,789,14,2142,1113,323
```
新增完成後，上傳至 HDFS 或者 OpenStack Swift 上，以下為 HDFS 範例：
```sh
$ hadoop fs -mkdir -p /spark/hw
$ hadoop fs -put test.txt /spark/hw
```

### 消費前20名 Dataset
找出當月消費前20名商品的範例，請下載[商品交易 Log](http://files.imaclouds.com/dataset/HMC-Contest.log)並透過 ```grep``` 前處理來，完成後上傳至 HDFS：
```sh
$ wget http://files.imaclouds.com/dataset/HMC-Contest.log
$ grep -o "act=order;uid=\w*\>;plist=[0-9,]*\>" HMC-Contest.log > preprocessed.csv
$ hadoop fs -put preprocessed.csv /spark/hw
```
> 資料前處理可以考慮是否要進行，若在 Hadoop MR 中，可以減少迭代次數，但由於 Spark 善於這樣的工作，但會影響程式撰寫方式。

### 執行方式
由於本次教學是部署於 YARN 之上的 Spark，若要提交一個分析 Application，可以使用以下指令：
```sh
$ spark-submit --class com.imac.hot.Analysis \
--master yarn-cluster HotAnalysis.jar \
/spark/hw/mine_data.csv \
/spark/hw/hot_output
```
> 第一行```--class``` 後面接 Main 函式的 ```package name``` 與 ```class name```。

> 第二行 ```--master``` 為使用叢集模式，這邊採用```yarn-cluster```。

> 第三行與第四行為```輸入資料```與```輸出目錄```。