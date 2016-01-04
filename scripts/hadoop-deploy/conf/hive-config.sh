#!/bin/bash
# Program:
#       This program is Hive configuration.
# History:
# 2015/1/02 Kyle.b Release
# 
# Configuration Hive 
# 
function CONFIG_HIVE_SITE {

local HOST=${1:-"localhost"}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
<property>
  <name>hive.metastore.execute.setugi</name>
  <value>true</value>
</property>
<property>
  <name>hive.metastore.warehouse.dir</name>
  <value>/user/hive/warehouse</value>
  <description>location of default database for the warehouse</description>
</property>
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:mysql://${HOST}:3306/hive?createDatabaseIfNotExist=true</value>
  <description>JDBC connect string for a JDBC metastore</description>
</property>
<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>com.mysql.jdbc.Driver</value>
  <description>Driver class name for a JDBC metastore</description>
</property>
<property>
  <name>javax.jdo.option.ConnectionUserName</name>
  <value>hive</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionPassword</name>
  <value>hive</value>
</property>
<property> 
  <name>system:java.io.tmpdir</name> 
  <value>/usr/local/hadoop_store/hive-tmp</value> 
</property> 
</configuration>"
}