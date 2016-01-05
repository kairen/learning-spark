#!/bin/bash
# Program:
#       This program is install hadoop.
# History:
# 2015/12/27 Kyle.b Release
# 
function master-install {
	array=("$@")
	arraylength=${#array[@]}

	CHECK_OPTIONS=("--spark" "--hbase" "--hive" "--version" "--ignore" "--spark-version")
	check_options $@
	
	SPARK_INDEX=$(index "--spark" ${array[@]})
	VERSION_INDEX=$(index "--version" ${array[@]})
	IGNORE_INDEX=$(index "--ignore" ${array[@]})
	HBASE_INDEX=$(index "--hbase" ${array[@]})
	HIVE_INDEX=$(index "--hive" ${array[@]})
	SPARK_VERSION_INDEX=$(index "--spark-version" ${array[@]})

	check_bool ${SPARK_INDEX} "${array[SPARK_INDEX]}" "--spark"
	SPARK=${RETURE_VALUE}

	check_pattern ${VERSION_INDEX} "[0-9].[0-9].[0-9]" "${array[VERSION_INDEX]}" "--version"
	VERSION=${RETURE_VALUE}

	check_bool ${IGNORE_INDEX} "${array[IGNORE_INDEX]}" "--ignore"
	IGNORE=${RETURE_VALUE}

	check_bool ${HBASE_INDEX} "${array[HBASE_INDEX]}" "--hbase"
	HBASE=${RETURE_VALUE}

	check_bool ${HIVE_INDEX} "${array[HIVE_INDEX]}" "--hive"
	HIVE=${RETURE_VALUE}

	check_pattern ${SPARK_VERSION_INDEX} "[0-9].[0-9].[0-9]" "${array[SPARK_VERSION_INDEX]}" "--spark-version"
	SPARK_VERSION=${RETURE_VALUE}


	local spark=${SPARK:-"true"}
	local version=${VERSION:-"2.6.0"}
	local ignore=${IGNORE:-"false"}
	local hbase=${HBASE:-"false"}
	local hive=${HIVE:-"false"}
	local spark_version=${SPARK_VERSION:-"1.5.2"}
	
	msg "Spark： $spark" "Configuraion"
	msg "Spark Version： $spark_version" "Configuraion"
	msg "HBase： $hbase" "Configuraion"
	msg "HIVE： $hive" "Configuraion"
	msg "Ignore install： $ignore" "Configuraion"
	msg "Hadoop Version： $version" "Configuraion"

	begin=$(max $MASTER_INDEX $VERSION_INDEX $IGNORE_INDEX $HBASE_INDEX $HIVE_INDEX $SPARK_VERSION_INDEX)

	if [ -z "${array[$begin+1]}" ]; then
		msg "No host ..." "ERROR"
		exit 1
	fi

	for (( i=$begin+2; i<${arraylength}+1; i++ )); do
		echo "Processing ${array[$i-1]} "

		ProgressBar 5 25
		msg "Installing oracle java8 ....."
   		install_jdk ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 8 25
   		msg "Installing other packages .."
   		install_other ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 13 25 
   		msg "Automatically generated ssh keys .."
   		ssh-config ${array[$i-1]} &>/dev/null

   		ProgressBar 16 25 
   		msg "Installing Apache Hadoop .."
   		install_hadoop ${version} ${array[$i-1]} &>/dev/null
   		hadoop-env-config ${version} ${array[$i-1]} ${array[$i-1]} &>/dev/null
   		
   		if [ $hbase == "true" ]; then
   			ProgressBar 20 25 
   			msg "Installing Apache HBase .."
   			install_hbase "true" ${array[$i-1]} &>/dev/null
   			hbase-config "true" ${array[$i-1]} ${array[$i-1]} &>/dev/null
   		fi

   		if [ $hive == "true" ]; then
   			ProgressBar 22 25 
   			msg "Installing Apache Hive .."
   			install_hive ${array[$i-1]} &>/dev/null
   			hive-mysql-config ${array[$i-1]} &>/dev/null
   			hive-config ${version} ${array[$i-1]}  &>/dev/null
   		fi

   		if [ $spark == "true" ]; then
   			ProgressBar 24 25 
   			msg "Installing Apache Spark .."
   			install_spark ${spark_version} ${array[$i-1]} &>/dev/null
   			spark-env-config ${version} ${array[$i-1]} &>/dev/null
   		fi

   		ProgressBar 25 25 
   		msg "Install Finish .."
	done
	
	msg "Using \"/opt/hadoop-${version}/sbin/start-dfs.sh\" to start HDFS ..."
	msg "Using \"/opt/hadoop-${version}/sbin/start-yarn.sh\" to start YARN ..."
	
	if [ $hbase == "true" ]; then
		msg "Using \"hadoop fs -mkdir /hbase\" to create hbase dir on HDFS ..." "HBASE INFO"
		msg "Using \"/opt/hbase-1.1.2/bin/start-hbase.sh\" to start service ..." "HBASE INFO"
	fi

	if [ $hive == "true" ]; then
		msg "Using \"hadoop fs -mkdir /tmp\" to create hive dir on HDFS ..." "HIVE INFO"
		msg "Using \"hadoop fs -mkdir -p /user/hive/warehouse\" to create hive dir on HDFS ..." "HIVE INFO"
		msg "Using \"/opt/hive/bin/hive --service metastore &\" to start metastore service ..." "HIVE INFO"
	fi

}