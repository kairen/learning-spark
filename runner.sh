#!/bin/bash
# Program:
#       This program is run spark job ....
# History:
# 2015/12/16 Kyle.b Release


sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Hadoop/Spark env configuration
export HADOOP_HOME="/opt/hadoop-2.6.0"
export PATH=$PATH:$HADOOP_HOME
export HADOOP_BIN="/opt/hadoop-2.6.0/bin"
export PATH=$PATH:$HADOOP_BIN
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$PATH

# Runner configuration
export SPARK_PACKAGE='com.imac.example.SparkExample'
export SPARK_MASTER='yarn-cluster'
export SPARK_JAR_PATH='out/artifacts/SparkExample_jar/SparkExample.jar'
export SPARK_INPUT='/spark/hw/test.txt'
export SPARK_OUTPUT='/spark/hw/output'

# hadoop fs -rm -r $SPARK_OUTPUT

spark-submit --class $SPARK_PACKAGE \
--master $SPARK_MASTER \
$SPARK_JAR_PATH \
$SPARK_INPUT \
$SPARK_OUTPUT


# echo result
export RESULT_FILE="part-00000";
for DIR in "map" "flatMap" "filter" "mapPair" "flatMapPair" "groupBy" "reduce" "reduceByKey"
do
        echo "------------ [ $DIR result ] ------------";
        hadoop fs -cat "$SPARK_OUTPUT/$DIR/$RESULT_FILE";
done