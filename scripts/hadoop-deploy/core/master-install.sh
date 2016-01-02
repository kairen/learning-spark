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

	check_bool ${SPARK_INDEX} "${array[SPARK_INDEX]}" "--spark"
	SPARK=${RETURE_VALUE}

	check_pattern ${VERSION_INDEX} "[0-9].[0-9].[0-9]" "${array[VERSION_INDEX]}" "--version"
	VERSION=${RETURE_VALUE}

	local spark=${SPARK:-"true"}
	local version=${VERSION:-"2.6.0"}
	
	begin=$(max $SPARK_INDEX $VERSION_INDEX)

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
   		msg "Installing other packages ....."
   		install_other ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 15 25
   		msg "Automatically generated ssh keys ....."
   		ssh-config ${array[$i-1]} &>/dev/null

   		ProgressBar 20 25
   		msg "Installing Hadoop ....."
   		install_hadoop ${version} ${array[$i-1]} &>/dev/null
   		hadoop-env-config ${version} ${array[$i-1]} ${array[$i-1]} &>/dev/null
   		
   		ProgressBar 23 25
   		if [ $spark == "true" ]; then
   			msg "Installing Spark ...."
   			install_spark "1.5.2" ${array[$i-1]} &>/dev/null
   			spark-env-config ${version} ${array[$i-1]} &>/dev/null
   		fi

   		ProgressBar 25 25
   		msg "Install Finish ...."
	done

	msg "Now, Using \"/opt/hadoop-${version}/sbin/start-all.sh\" to start service ..."
}