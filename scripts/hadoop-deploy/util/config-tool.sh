#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/27 Kyle.b Release
# 
function ssh-config {
	scp conf/expect.sh $1:~/
	cmd $1 "sh expect.sh"
	cmd $1 "rm -rf expect.sh"
	cmd $1 'cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys'
}

function hadoop-env-config {
	HDFS_SITE="hdfs-site.xml"
	CORE_SITE="core-site.xml"
	MAPRED_SITE="mapred-site.xml"
	YARN_SITE="yarn-site.xml"
	HADOOP_ENV="hadoop-env.sh"
	HADOOP_HOME="/opt/hadoop-${1}"
	EXPOST="export JAVA_HOME=/usr/lib/jvm/java-8-oracle"
    USER_NAEM=$(cmd $2 'echo $(whoami)')

	cmd $2 "sudo chown -R ${USER_NAEM}:${USER_NAEM} ${HADOOP_HOME}"
	cmd $2 "sudo rm -rf /usr/local/hadoop_store"
	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/tmp"
	cmd $2 'sudo chown $(whoami):$(whoami) /usr/local/hadoop_store/tmp'
	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode"
	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode"
	cmd $2 'sudo chown -R $(whoami):$(whoami) /usr/local/hadoop_store'

	ENV_PATH="${HADOOP_HOME}/etc/hadoop/${HADOOP_ENV}"
	echo ${EXPOST} | cmd $2 "sudo tee -a ${ENV_PATH}"

	CORE_PATH="${HADOOP_HOME}/etc/hadoop/${CORE_SITE}"
	cmd $2  "sudo rm -rf ${CORE_PATH}"
	CONFIG_CORE_SITE $3 | cmd $2 "sudo tee ${CORE_PATH}"

	HDFS_PATH="${HADOOP_HOME}/etc/hadoop/${HDFS_SITE}"
	cmd $2  "sudo rm -rf ${HDFS_PATH}"
	CONFIG_HDFS_SITE $3 | cmd $2 "sudo tee ${HDFS_PATH}"

	MAPRED_PATH="${HADOOP_HOME}/etc/hadoop/${MAPRED_SITE}"
	cmd $2  "sudo rm -rf ${MAPRED_PATH}"
	CONFIG_MAPRED_SITE $3 | cmd $2 "sudo tee ${MAPRED_PATH}"

	YARN_PATH="${HADOOP_HOME}/etc/hadoop/${YARN_SITE}"
	cmd $2  "sudo rm -rf ${YARN_PATH}"
	CONFIG_YARN_SITE $3 | cmd $2 "sudo tee ${YARN_PATH}"

	cmd $2 "${HADOOP_HOME}/bin/hadoop namenode -format"

	echo "export HADOOP_HOME=\"${HADOOP_HOME}\"" | cmd $2 "sudo tee -a ~/.bashrc"
	echo "export PATH=\$PATH:\$HADOOP_HOME" | cmd $2 "sudo tee -a ~/.bashrc"

	echo "export HADOOP_BIN=\"${HADOOP_HOME}/bin\"" | cmd $2 "sudo tee -a ~/.bashrc"
	echo "export PATH=\$PATH:\$HADOOP_BIN" | cmd $2 "sudo tee -a ~/.bashrc"

}

function spark-env-config {
	cmd $2 'sudo chown -R $(whoami):$(whoami) /opt/spark'

	echo "export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | cmd $2 "sudo tee -a /opt/spark/conf/spark-env.sh"
	echo "export YARN_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | cmd $2 "sudo tee -a /opt/spark/conf/spark-env.sh"
	echo "export SPARK_HOME=/opt/spark" | cmd $2 "sudo tee -a /opt/spark/conf/spark-env.sh"
	echo "export SPARK_JAR=/opt/spark/lib/spark-assembly-1.5.2-hadoop2.6.0.jar" | cmd $2 "sudo tee -a /opt/spark/conf/spark-env.sh"
	echo "export PATH=\$SPARK_HOME/bin:\$PATH" | cmd $2 "sudo tee -a /opt/spark/conf/spark-env.sh"

	echo "export SPARK_HOME=/opt/spark" | cmd $2 "sudo tee -a ~/.bashrc"
    echo "export PATH=\$SPARK_HOME/bin:\$PATH" | cmd $2 "sudo tee -a ~/.bashrc"
}	

function hadoop-slave-config {
	HADOOP_HOME="/opt/hadoop-${1}"

	SLAVES_NAME="slaves"
	SLAVES_PATH="${HADOOP_HOME}/etc/hadoop/${SLAVES_NAME}"
	cmd $2  "sudo rm -rf ${SLAVES_PATH}"
	echo -e $3 | cmd $2 "sudo tee ${SLAVES_PATH}"
}

function hbase-config {
	if [ "$1" == "true" ]; then
		echo "server.1=${2}:2888:3888" | cmd $2 "sudo tee -a /etc/zookeeper/conf/zoo.cfg"
		echo "1" | cmd $2 "sudo tee /etc/zookeeper/conf/myid"
		cmd $2 "sudo service zookeeper restart"
	fi
	
	HBASE_SITE="hbase-site.xml"
	HBASE_HOME="/opt/hbase-1.1.2"
	USER_NAEM=$(cmd $2 'echo $(whoami)')

	cmd $2 "sudo chown -R ${USER_NAEM}:${USER_NAEM} ${HBASE_HOME}"

	EXPOST="export JAVA_HOME=/usr/lib/jvm/java-8-oracle"
	MANAGES_ZK="export HBASE_MANAGES_ZK=false"
	echo ${EXPOST} | cmd $2 "sudo tee -a ${HBASE_HOME}/conf/hbase-env.sh"
	echo ${MANAGES_ZK} | cmd $2 "sudo tee -a ${HBASE_HOME}/conf/hbase-env.sh"

	HBASE_SITE_PATH="${HBASE_HOME}/conf/${HBASE_SITE}"
	CONFIG_HBASE_SITE $3 | cmd $2 "sudo tee ${HBASE_SITE_PATH}"

	echo "export HBASE_HOME=$HBASE_HOME" | cmd $2 "sudo tee -a ~/.bashrc"
	echo "export PATH=\$PATH:\$HBASE_HOME/bin" | cmd $2 "sudo tee -a ~/.bashrc"
}

function hbase-slave-config {
	HBASE_HOME="/opt/hbase-1.1.2"

	SLAVES_NAME="regionservers"
	SLAVES_PATH="${HBASE_HOME}/conf/${SLAVES_NAME}"
	cmd $1  "sudo rm -rf ${SLAVES_PATH}"
	echo -e $2 | cmd $1 "sudo tee ${SLAVES_PATH}"
}
