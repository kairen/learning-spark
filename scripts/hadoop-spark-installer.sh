#!/bin/bash
# Program:
#       This program is install hadoop/spark on your server.
# History:
# 2015/10/19 Kyle.b Release


USER_NAME=$(whoami)

if [[ -z $USER_NAME ]]; then
	echo "ERROR : "
	echo "請建立環境參數，ex: [ export USER_NAME=\"ubuntu\" ]"
	exit 1
fi

whiptail --title "安裝訊息" --msgbox "本腳本將安裝Hadoop與Spark於單一節點上。若有問題請找2114長老室。選擇<Ok>進行安裝。" 10 61

HADOOP_SOURCE_NAME=$(whiptail --title "安裝訊息" --radiolist \
"選擇要安裝的Hadoop版本" 15 60 4 \
"hadoop-2.6.0" "Apache Hadoop 2.6.0 版本(建議)" ON \
"hadoop-2.6.1" "Apache Hadoop 2.6.1 版本" OFF  3>&1 1>&2 2>&3)

if [[ -z $HADOOP_SOURCE_NAME ]]; then
        echo "ERROR : "
        echo "請建立安裝版本環境參數，ex:[ export HADOOP_SOURCE_NAME=\"hadoop-2.6.0\" ]"
	exit 1
fi

SPARK_FLAG=true
if (whiptail --title "安裝訊息" --yesno "您是否要安裝Apache Spark？" 10 60) then
    SPARK_FLAG=true
    echo "Install Spark ...."
else
    SPARK_FLAG=false
    echo "Skip Install Spark ...."
fi


HOST_NAME=$(hostname)
echo "127.0.1.1  $(hostname)" | sudo tee -a /etc/hosts

# install java oracle
echo "$USER_NAME ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER_NAME && sudo chmod 440 /etc/sudoers.d/$USER_NAME
sudo apt-get purge openjdk*
sudo apt-get -y autoremove
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java7-installer

#install ssh
sudo apt-get install -y openssh-server expect


expect -c "
spawn ssh-keygen -t rsa -P \"\"
expect \"Enter passphrase (empty for no passphrase):\"
send \"\r\"
expect \"Enter same passphrase again:\"
send \"\r\"
"

cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
ssh -o StrictHostKeyChecking=no localhost echo "Login Ok...."
ssh -o StrictHostKeyChecking=no 0.0.0.0 echo "Login Ok...."

#download hadoop
sudo chmod -R 777 /opt/
cd /opt/

if ls /opt | grep -Fxq "$HADOOP_SOURCE_NAME"
then
    echo "Found"
    tar xvzf $HADOOP_SOURCE_NAME.tar.gz
else
    echo "Not Found... "
    wget http://files.imaclouds.com/packages/hadoop/$HADOOP_SOURCE_NAME.tar.gz
    tar xvzf $HADOOP_SOURCE_NAME.tar.gz
fi

##delete file
cd /opt/$HADOOP_SOURCE_NAME/etc/hadoop/
sudo rm -rf core-site.xml
sudo rm -rf mapred-site.xml.template
sudo rm -rf hdfs-site.xml
sudo rm -rf yarn-site.xml

#hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-7-oracle' >> /opt/$HADOOP_SOURCE_NAME/etc/hadoop/hadoop-env.sh

##core-site.xml
sudo mkdir -p /app/hadoop/tmp
sudo chown $USER:$USER /app/hadoop/tmp

echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property><property><name>hadoop.tmp.dir</name><value>/app/hadoop/tmp</value><description>A base for other temporary directories.</description></property></configuration>' >> /opt/$HADOOP_SOURCE_NAME/etc/hadoop/core-site.xml

##mapred-site.xml
echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>mapreduce.framework.name</name><value>yarn</value></property></configuration>' >> /opt/$HADOOP_SOURCE_NAME/etc/hadoop/mapred-site.xml

##hdfs-site.xml
sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode
sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode
sudo chown -R $USER:$USER /usr/local/hadoop_store

echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>dfs.replication</name><value>1</value></property><property><name>dfs.namenode.name.dir</name><value>/usr/local/hadoop_store/hdfs/namenode</value></property><property><name>dfs.datanode.data.dir</name><value>/usr/local/hadoop_store/hdfs/datanode</value></property></configuration>' >> /$HADOOP_SOURCE_NAME/etc/hadoop/hdfs-site.xml

## yarn-site.xml
echo '<?xml version="1.0"?><configuration><property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property></configuration>' >> /opt/$HADOOP_SOURCE_NAME/etc/hadoop/yarn-site.xml

#namenode format
/opt/$HADOOP_SOURCE_NAME/bin/hadoop namenode -format

#start hadoop
/opt/$HADOOP_SOURCE_NAME/sbin/start-yarn.sh
/opt/$HADOOP_SOURCE_NAME/sbin/start-dfs.sh

#check result
jps

echo "export HADOOP_HOME=\"/opt/$HADOOP_SOURCE_NAME\"" | sudo tee -a ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME" | sudo tee -a ~/.bashrc
echo "export HADOOP_BIN=\"/opt/$HADOOP_SOURCE_NAME/bin\"" | sudo tee -a ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_BIN" | sudo tee -a ~/.bashrc
source ~/.bashrc

# Install Spark
if [ "$SPARK_FLAG" = true ]; then
    echo "Install Spark ...."
    curl -s http://files.imaclouds.com/packages/hadoop-spark/spark-1.6.1-bin-hadoop2.6.tgz | sudo tar -xz -C /opt/
    sudo mv /opt/spark-1.6.1-bin-hadoop2.6 /opt/spark
    sudo chown $USER_NAME:$USER_NAME -R /opt/spark
    echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export SPARK_HOME=/opt/spark" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export SPARK_JAR=/opt/spark/lib/spark-assembly-1.6.1-hadoop2.6.0.jar" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a /opt/spark/conf/spark-env.sh

    echo "export SPARK_HOME=/opt/spark" | sudo tee -a ~/.bashrc
    echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a ~/.bashrc

else
    echo "Skip Install Spark ...."
fi

# spark-submit --class org.apache.spark.examples.SparkPi \
# --master yarn-cluster \
# --num-executors 1 \
# --executor-memory 1g \
# --executor-cores 1 \
# lib/spark-examples*.jar \
# 1
