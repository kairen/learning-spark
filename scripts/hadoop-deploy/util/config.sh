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
	cmd $1 "cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys"
}

function hadoop-env-config {

	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/tmp"
	cmd $2 "sudo chown $USER:$USER /usr/local/hadoop_store/tmp"
	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode"
	cmd $2 "sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode"
	cmd $2 "sudo chown -R $USER:$USER /usr/local/hadoop_store"

	HDFS_SITE="hdfs-site.xml"
	CORE_SITE="core-site.xml"
	MAPRED_SITE="mapred-site.xml"
	YARN_SITE="yarn-site.xml"
	HADOOP_ENV="hadoop-env.sh"

	EXPOST="export JAVA_HOME=/usr/lib/jvm/java-8-oracle"
	HADOOP_HOME="/opt/hadoop-${1}/etc/hadoop/"
	ENV_PATH="${HADOOP_HOME}${HADOOP_ENV}"
	echo ${EXPOST} | cmd $2 "sudo tee -a ${ENV_PATH}"

	CORE_PATH="${HADOOP_HOME}${CORE_SITE}"
	cmd $2  "sudo rm -rf ${CORE_PATH}"
	CONFIG_CORE_SITE $2 | cmd $2 "sudo tee ${CORE_PATH}"

	HDFS_PATH="${HADOOP_HOME}${HDFS_SITE}"
	cmd $2  "sudo rm -rf ${HDFS_PATH}"
	CONFIG_HDFS_SITE $2 | cmd $2 "sudo tee ${HDFS_PATH}"

	MAPRED_PATH="${HADOOP_HOME}${MAPRED_SITE}"
	cmd $2  "sudo rm -rf ${MAPRED_PATH}"
	CONFIG_MAPRED_SITE $2 | cmd $2 "sudo tee ${MAPRED_PATH}"

	YARN_PATH="${HADOOP_HOME}${YARN_SITE}"
	cmd $2  "sudo rm -rf ${YARN_PATH}"
	CONFIG_YARN_SITE $2 | cmd $2 "sudo tee ${YARN_PATH}"
}


