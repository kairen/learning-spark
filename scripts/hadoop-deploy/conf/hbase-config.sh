#!/bin/bash
# Program:
#       This program is Hbase configuration.
# History:
# 2015/1/02 Kyle.b Release
# 
# Configuration Hbase 
# 
function CONFIG_HBASE_SITE {

local HOST=${1:-"localhost"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://${HOST}:9000/hbase</value>
  </property>
  <property>
    <name>hbase.master</name>
    <value>hdfs://${HOST}:60000</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.clientPort</name>
    <value>2181</value>
  </property>
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>${HOST}</value>
  </property>
  <property>  
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/var/lib/zookeeper</value>  
  </property>
  <property>  
    <name>hbase.client.scanner.caching</name>
    <value>200</value>  
  </property>
  <property>
    <name>hbase.balancer.period</name>
    <value>300000</value>
  </property>
  <property>
    <name>hbase.client.write.buffer</name>
    <value>10485760</value>
  </property>
  <property>
    <name>hbase.hregion.majorcompaction</name>
    <value>7200000</value>
  </property>
  <property>
    <name>hbase.hregion.max.filesize</name>
    <value>67108864</value>
  </property>
  <property>
    <name>hbase.hregion.memstore.flush.size</name>
    <value>1048576</value>
  </property>
  <property>
    <name>hbase.server.thread.wakefrequency</name>
    <value>30000</value>
  </property>
</configuration>"
}