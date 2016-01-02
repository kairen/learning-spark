#!/bin/bash
# Program:
#       This program is install hadoop.
# History:
# 2015/12/27 Kyle.b Release
# 
function master-install {
	array=("$@")
	arraylength=${#array[@]}

	CHECK_OPTIONS=("--spark" "--hbase" "--version" "--ignore")
	check_options $@
	
	SPARK_INDEX=$(index "--spark" ${array[@]})
	VERSION_INDEX=$(index "--version" ${array[@]})
	IGNORE_INDEX=$(index "--ignore" ${array[@]})
	HBASE_INDEX=$(index "--hbase" ${array[@]})

	check_bool ${SPARK_INDEX} "${array[SPARK_INDEX]}" "--spark"
	SPARK=${RETURE_VALUE}

	check_pattern ${VERSION_INDEX} "[0-9].[0-9].[0-9]" "${array[VERSION_INDEX]}" "--version"
	VERSION=${RETURE_VALUE}

	check_bool ${IGNORE_INDEX} "${array[IGNORE_INDEX]}" "--ignore"
	IGNORE=${RETURE_VALUE}

	check_bool ${HBASE_INDEX} "${array[HBASE_INDEX]}" "--hbase"
	HBASE=${RETURE_VALUE}

	local spark=${SPARK:-"true"}
	local version=${VERSION:-"2.6.0"}
	local ignore=${IGNORE:-"false"}
	local hbase=${HBASE:-"false"}
	
	msg "Spark： $spark" "Configuraion"
	msg "HBase： $hbase" "Configuraion"
	msg "Ignore install： $ignore" "Configuraion"
	msg "Version： $version" "Configuraion"

	begin=$(max $MASTER_INDEX $VERSION_INDEX $IGNORE_INDEX $HBASE_INDEX)

	if [ -z "${array[$begin+1]}" ]; then
		msg "No host ..." "ERROR"
		exit 1
	fi

	for (( i=$begin+2; i<${arraylength}+1; i++ )); do
		echo "Processing ${array[$i-1]} "

		ProgressBar 5 25
		msg "Installing oracle java8 ....."
   		install_jdk ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 10 25
   		msg "Installing other packages .."
   		install_other ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 15 25 
   		msg "Automatically generated ssh keys .."
   		ssh-config ${array[$i-1]} &>/dev/null

   		ProgressBar 18 25 
   		msg "Installing Apache Hadoop .."
   		install_hadoop ${version} ${array[$i-1]} &>/dev/null
   		hadoop-env-config ${version} ${array[$i-1]} ${array[$i-1]} &>/dev/null
   		
   		if [ $hbase == "true" ]; then
   			ProgressBar 20 25 
   			msg "Installing Apache HBase .."
   			install_hbase "true" ${array[$i-1]} &>/dev/null
   			hbase-config "true" ${array[$i-1]} ${array[$i-1]} &>/dev/null
   		fi

   		if [ $spark == "true" ]; then
   			ProgressBar 23 25 
   			msg "Installing Apache Spark .."
   			install_spark "1.5.2" ${array[$i-1]} &>/dev/null
   			spark-env-config ${version} ${array[$i-1]} &>/dev/null
   		fi

   		ProgressBar 25 25 
   		msg "Install Finish .."
	done
	
	msg "Using \"/opt/hadoop-${version}/sbin/start-all.sh\" to start service ..."
	
	if [ $hbase == "true" ]; then
		hbase-slave-config ${master} ${SLAVES} &>/dev/null
		msg "Using \"hadoop fs -mkdir /hbase\" to create hbase dir on HDFS ..."
		msg "Using \"/opt/hbase-1.1.2/bin/start-hbase.sh\" to start service ..."
	fi
}