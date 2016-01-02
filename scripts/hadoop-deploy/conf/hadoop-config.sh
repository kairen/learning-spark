#!/bin/bash
# Program:
#       This program is Hadoop configuration
# History:
# 2015/12/28 Kyle.b Release
# 
# Configuration Hadoop core site
# 
function CONFIG_CORE_SITE {

local HOST=${1:-"localhost"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://${HOST}:9000</value>
</property>
<property>
    <name>io.file.buffer.size</name>
    <value>131072</value>
</property>
<property>
    <name>hadoop.tmp.dir</name>
    <value>/usr/local/hadoop_store/tmp</value>
</property>
<property>
    <name>hadoop.proxyuser.hduser.hosts</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.hduser.groups</name>
    <value>*</value>
</property>
</configuration>"
}

# 
# Configuration Hadoop core site
# 
function CONFIG_HDFS_SITE {

local HOST=${1:-"localhost"}
local REPLICA=${2:-"1"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>${HOST}:9001</value>
</property>
<property>
    <name>dfs.namenode.name.dir</name>
    <value>/usr/local/hadoop_store/hdfs/namenode</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>/usr/local/hadoop_store/hdfs/datanode</value>
</property>
<property>
    <name>dfs.replication</name>
    <value>${REPLICA}</value>
</property>
<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
</property>
</configuration>"
}

# 
# Configuration Hadoop core site
# 
function CONFIG_MAPRED_SITE {

local HOST=${1:-"localhost"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
<property>
    <name>mapreduce.jobhistory.address</name>
    <value>${HOST}:10020</value>
</property>
<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>${HOST}:19888</value>
</property>
</configuration>"
}

# 
# Configuration Hadoop core site
# 
function CONFIG_YARN_SITE {

local HOST=${1:-"localhost"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
    <name>yarn.resourcemanager.address</name>
    <value>${HOST}:8032</value>
</property>
<property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>${HOST}:8030</value>
</property>
<property>
    <name>yarn.resourcemanager.resource-tracker.address</name>
    <value>${HOST}:8031</value>
</property>
<property>
    <name>yarn.resourcemanager.admin.address</name>
    <value>${HOST}:8033</value>
</property>
<property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>${HOST}:8088</value>
</property>
</configuration>"
}