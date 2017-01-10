#!/bin/bash
# Program:
#       This program is install hadoop/spark on your server.
# History:
# 2017/1/10 Max.J Release


USER_NAME=$(whoami)

if [[ -z ${USER_NAME} ]]; then
	echo "ERROR : "
	echo "請建立環境參數，ex: [ export USER_NAME=\"ubuntu\" ]"
	exit 1
fi

whiptail --title "安裝訊息" --msgbox "本腳本將安裝 Hadoop 與 Spark 於單一節點上。若有問題請找 2114 長老室。選擇<Ok>進行安裝。" 10 61

HADOOP_SOURCE_NAME=$(whiptail --title "安裝訊息" --radiolist \
"選擇要安裝的 Hadoop 版本" 15 60 4 \
"hadoop-2.7.3" "Apache Hadoop 2.7.3 版本(建議)" ON  3>&1 1>&2 2>&3)

if [[ -z ${HADOOP_SOURCE_NAME} ]]; then
        echo "ERROR : "
        echo "請建立安裝版本環境參數，ex:[ export HADOOP_SOURCE_NAME=\"hadoop-2.6.5\" ]"
	exit 1
fi

SPARK_FLAG=true
if (whiptail --title "安裝訊息" --yesno "您是否要安裝Apache Spark？" 10 60) then
    SPARK_FLAG=true
	SPARK_VER=$(whiptail --title "安裝訊息" --radiolist \
	"選擇要安裝的 Spark 版本" 15 60 4 \
	"1.5.2" "Apache Spark 1.5.2 版本" ON \
	"1.6.0" "Apache Spark 1.6.0 版本" OFF \
	"1.6.1" "Apache Spark 1.6.1 版本" OFF \
	"2.0.0" "Apache Spark 2.0.0 版本" OFF 3>&1 1>&2 2>&3)
else
    SPARK_FLAG=false
    echo "Skip Install Spark ...."
fi

FLINK_FLAG=true

if (whiptail --title "安裝訊息" --yesno "您是否要安裝Apache Flink？" 10 60) then
    FLINK_FLAG=true
else
    FLINK_FLAG=false
    echo "Skip Install Flink ...."
fi



HOST_NAME=$(hostname)
sudo sed "2c 127.0.1.1 $(hostname)" -i /etc/hosts

# install java oracle
echo "${USER_NAME} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USER_NAME} && sudo chmod 440 /etc/sudoers.d/${USER_NAME}
sudo apt-get purge openjdk*
sudo apt-get -y autoremove
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

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

if ls /opt | grep -Fxq "${HADOOP_SOURCE_NAME}"
then
    echo "Found"
    tar xvzf ${HADOOP_SOURCE_NAME}.tar.gz
else
    echo "Not Found... "
    wget http://ftp.mirror.tw/pub/apache/hadoop/common/${HADOOP_SOURCE_NAME}/${HADOOP_SOURCE_NAME}.tar.gz
    tar xvzf ${HADOOP_SOURCE_NAME}.tar.gz
fi

##delete file
cd /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/
sudo rm -rf core-site.xml
sudo rm -rf mapred-site.xml.template
sudo rm -rf hdfs-site.xml
sudo rm -rf yarn-site.xml

#hadoop-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-7-oracle' >> /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/hadoop-env.sh

##core-site.xml
sudo mkdir -p /app/hadoop/tmp
sudo chown ${USER}:${USER} /app/hadoop/tmp

echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property><property><name>hadoop.tmp.dir</name><value>/app/hadoop/tmp</value><description>A base for other temporary directories.</description></property></configuration>' >> /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/core-site.xml

##mapred-site.xml
echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>mapreduce.framework.name</name><value>yarn</value></property></configuration>' >> /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/mapred-site.xml

sudo mkdir -p /usr/local/hadoop/tmp/dfs/name/current/
sudo chown -R ${USER}:${USER} /usr/local/hadoop
##hdfs-site.xml
echo '<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>dfs.replication</name><value>1</value></property><property><name>dfs.namenode.name.dir</name><value>file:/usr/local/hadoop/tmp/dfs/name</value></property><property><name>dfs.datanode.data.dir</name><value>file:/usr/local/hadoop/tmp/dfs/data</value></property><property><name>dfs.permissions</name><value>false</value></property></configuration>' >> /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/hdfs-site.xml

##yarn-site.xml
echo '<?xml version="1.0"?><configuration><property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property></configuration>' >> /opt/${HADOOP_SOURCE_NAME}/etc/hadoop/yarn-site.xml

#namenode format
/opt/${HADOOP_SOURCE_NAME}/bin/hadoop namenode -format <<EOF
reload
y
EOF


#start hadoop
/opt/${HADOOP_SOURCE_NAME}/sbin/start-yarn.sh
/opt/${HADOOP_SOURCE_NAME}/sbin/start-dfs.sh

#check result
jps

echo "export HADOOP_HOME=\"/opt/${HADOOP_SOURCE_NAME}\"" | sudo tee -a ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME" | sudo tee -a ~/.bashrc
echo "export HADOOP_BIN=\"/opt/${HADOOP_SOURCE_NAME}/bin\"" | sudo tee -a ~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_BIN" | sudo tee -a ~/.bashrc
source ~/.bashrc

# Install Spark
if [ "${SPARK_FLAG}" = true ]; then
    echo "Install Spark ...."
    #curl -s http://files.imaclouds.com/packages/spark/spark-${SPARK_VER}-bin-hadoop2.6.tgz | sudo tar -xz -C /opt/
    #curl -s http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VER}-bin-hadoop2.7.tgz | sudo tar -xz -C /opt/
    curl -s http://archive.apache.org/dist/spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop2.7.tgz | sudo tar -xz -C /opt/
    sudo mv /opt/spark-${SPARK_VER}-bin-hadoop2.7 /opt/spark
    sudo chown ${USER_NAME}:${USER_NAME} -R /opt/spark

    echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export SPARK_HOME=/opt/spark" | sudo tee -a /opt/spark/conf/spark-env.sh
    echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a /opt/spark/conf/spark-env.sh

    echo "export SPARK_HOME=/opt/spark" | sudo tee -a ~/.bashrc
    echo "export PATH=\$SPARK_HOME/bin:\$PATH" | sudo tee -a ~/.bashrc

else
    echo "Skip Install Spark ...."
fi

echo "Installation Finish ..."
echo "Please type : \"source .bashrc\""

# Install Flink

if [ "${FLINK_FLAG}" = true ]; then
    echo "Install Spark ...."
    curl -s ftp://ftp.twaren.net/Unix/Web/apache/flink/flink-1.1.2/flink-1.1.2-bin-hadoop27-scala_2.10.tgz | sudo tar -xz -C /opt/
    sudo /opt/flink-1.1.2/bin/start-local.sh
else
    echo "Skip Install FLINK ...."
fi
