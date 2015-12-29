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
	HDFS_SITE="hdfs-site.xml"
	CORE_SITE="core-site.xml"
	MAPRED_SITE="mapred-site.xml"
	YARN_SITE="yarn-site.xml"
	HADOOP_ENV="hadoop-env.sh"

	EXPOST="export JAVA_HOME=/usr/lib/jvm/java-8-oracle"
	HADOOP_HOME="/opt/hadoop-${1}/etc/hadoop/"
	ENV_PATH="${HADOOP_HOME}${HADOOP_ENV}"
	echo ${ENV_PATH}
	# echo ${EXPOST} | cmd $2 "sudo tee -a qsub ${ENV_PATH}"

	CORE_PATH="${HADOOP_HOME}${CORE_SITE}"
	# CONFIG_CORE_SITE $2 
	echo ${CORE_PATH}

	HDFS_PATH="${HADOOP_HOME}${HDFS_SITE}"
	# CONFIG_HDFS_SITE $2 
	echo ${CORE_PATH}

	MAPRED_PATH="${HADOOP_HOME}${MAPRED_SITE}"
	# CONFIG_MAPRED_SITE $2 
	echo ${MAPRED_PATH}

	YARN_PATH="${HADOOP_HOME}${YARN_SITE}"
	# CONFIG_YARN_SITE $2 
	echo ${YARN_PATH}
}


