#!/bin/bash
# Program:
#       This program is install hadoop.
# History:
# 2015/12/27 Kyle.b Release
# 
# 
function slave-install {
	array=("$@")
	arraylength=${#array[@]}

	CHECK_OPTIONS=("--master" "--hbase" "--version" "--ignore")
	check_options $@
	
	MASTER_INDEX=$(index "--master" ${array[@]})
	VERSION_INDEX=$(index "--version" ${array[@]})
	IGNORE_INDEX=$(index "--ignore" ${array[@]})
	HBASE_INDEX=$(index "--hbase" ${array[@]})

	check_value $MASTER_INDEX "${array[MASTER_INDEX]}" "--master"
	MASTER=${RETURE_VALUE}

	check_pattern $VERSION_INDEX "[0-9].[0-9].[0-9]" "${array[VERSION_INDEX]}" "--version"
	VERSION=${RETURE_VALUE}
	
	check_bool ${IGNORE_INDEX} "${array[IGNORE_INDEX]}" "--ignore"
	IGNORE=${RETURE_VALUE}

	check_bool ${HBASE_INDEX} "${array[HBASE_INDEX]}" "--hbase"
	HBASE=${RETURE_VALUE}

	if [ -z ${MASTER} ]; then
		msg "No master host ..." "ERROR"
		exit 1
	fi

	local master=${MASTER}
	local version=${VERSION:-"2.6.0"}
	local ignore=${IGNORE:-"false"}
	local hbase=${HBASE:-"false"}
	
	msg "Master IP： $master" "Configuraion"
	msg "HBase： $hbase" "Configuraion"
	msg "Ignore install： $ignore" "Configuraion"
	msg "Version： $version" "Configuraion"


	begin=$(max $MASTER_INDEX $VERSION_INDEX $IGNORE_INDEX $HBASE_INDEX)

	if [ -z "${array[$begin+1]}" ]; then
		msg "No slave host ..." "ERROR"
		exit 1
	fi

	SLAVES=""
	for (( i=$begin+2; i<${arraylength}+1; i++ )); do
		echo "Processing ${array[$i-1]} "
		ProgressBar 5 25
		msg "Installing oracle java 8 .."
   		install_jdk ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 10 25
   		msg "Installing other packages .."
   		install_other ${array[$i-1]} &>/dev/null
   		 
   		ProgressBar 15 25
   		msg "Automatically generated ssh keys .."
   		ssh-config ${array[$i-1]} &>/dev/null

   		ProgressBar 18 25
   		msg "Installing Hadoop .."
   		install_hadoop ${version} ${array[$i-1]} &>/dev/null
   		hadoop-env-config ${version} ${array[$i-1]} ${master} &>/dev/null

   		if [ $hbase == "true" ]; then
   			ProgressBar 22 25
   			msg "Installing HBase .."
   			install_hbase "false" ${array[$i-1]} &>/dev/null
   			hbase-config "false" ${array[$i-1]} ${master} &>/dev/null
   		fi

   		ProgressBar 25 25
   		msg "Install Finish .."

   		SLAVES="$SLAVES${array[$i-1]}\n"
	done

	hadoop-slave-config ${version} ${master} ${SLAVES} &>/dev/null
	msg "Using \"/opt/hadoop-${version}/sbin/start-dfs.sh\" to start HDFS ..."
	msg "Using \"/opt/hadoop-${version}/sbin/start-yarn.sh\" to start YARN ..."

	if [ $hbase == "true" ]; then
		hbase-slave-config ${master} ${SLAVES} &>/dev/null
		msg "Using \"hadoop fs -mkdir /hbase\" to create hbase dir on HDFS ..." "HBASE INFO"
		msg "Using \"/opt/hbase-1.1.2/bin/start-hbase.sh\" to start service ..." "HBASE INFO"
	fi

}