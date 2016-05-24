# Building Spark Source Code
本節將說明如何透過 mvn 與 sbt 來建置 Spark 最新版的相關檔案，透過提供最新版本來觀看 API 的變動。

### 事前準備
首先準備一台裝有 Ubuntu 14.04 LTS Server 作業系的主機或 Docker 容器。首先更改 Repos 來源：
```sh
odm="archive.ubuntu.com"
ndm="tw.archive.ubuntu.com"
sudo sed -i "s/${odm}/${ndm}/g" /etc/apt/sources.list
```
> P.S. ```odm```要依系統改變。

並安裝相關相依套件：
```sh
sudo apt-get purge openjdk*
sudo apt-get -y autoremove
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer git
```

接著安裝 maven 3.3.1 + 工具：
```sh
wget http://ftp.tc.edu.tw/pub/Apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -zxf apache-maven-3.3.9-bin.tar.gz
sudo cp -R apache-maven-3.3.9 /usr/local/
sudo ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
mvn --version
```

安裝 Scala：
```sh
wget www.scala-lang.org/files/archive/scala-2.11.7.deb
sudo dpkg -i scala-2.11.7.deb
```

安裝 sbt 工具：
```sh
echo "deb http://dl.bintray.com/sbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo apt-get update
sudo apt-get install sbt
```

安裝 Python 2.7：
```sh
$ sudo apt-get install python
```

透過 git 下載 Spark 專案到本地端：
```sh
$ git clone https://github.com/apache/spark.git
```

### 使用 sbt 來建置 spark
sbt 的 spark 建置指令如下所示，若使用 sbt 需要大約 10 分鐘時間：：
```sh
$ ./build/sbt -Pyarn -Phadoop-2.6 -Dhadoop.version=2.6.0 -Phive -Phive-thriftserver -DskipTests clean assembly
```

當建置完成後，可以透過 spark-shell 查看版本：
```sh
$ ./bin/spark-shell --version
```

### 使用 Apache Maven 來建置 spark
Apache Maven 的 spark 建置指令如下所示:
```sh
$ ./build/mvn -Pyarn -Phadoop-2.6 -Dhadoop.version=2.6.0 -Phive -Phive-thriftserver -DskipTests clean install
```

當建置完成後，可以透過 spark-shell 查看版本：
```sh
$ ./bin/spark-shell --version
```

### Making Distribution
make-distribution.sh 是一個 shell 腳本用於建立分散式應用。它使用跟 sbt 與 mvn 一樣的配置檔案。首先新增 Java 環境參數：
```sh
$ export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
```

使用 ```--tgz``` 選項去建立一個 tar gz 的 Spark 分散檔案：
```sh
$ ./dev/make-distribution.sh --tgz -Pyarn -Phadoop-2.6 -Dhadoop.version=2.6.0 -Phive -Phive-thriftserver -DskipTests
```
> 一旦完成後，你會在當前目錄看到檔案，名稱會是```spark-2.0.0-SNAPSHOT-bin-2.6.0.tgz```。
