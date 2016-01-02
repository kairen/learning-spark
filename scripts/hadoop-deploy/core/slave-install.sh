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
	
	local version=${VERSION:-"2.6.0"}
	local master=${MASTER}
	
	begin=$(max $MASTER_INDEX $VERSION_INDEX $IGNORE_INDEX $HBASE_INDEX)

	if [ -z "${array[$begin+1]}" ]; then
		msg "No slave host ..." "ERROR"
		exit 1
	fi

	SLAVES=""
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
   		hadoop-env-config ${version} ${array[$i-1]} ${master} &>/dev/null

   		ProgressBar 25 25
   		msg "Install Finish ...."

   		SLAVES="$SLAVES${array[$i-1]}\n"
	done

	hadoop-slave-config ${version} ${master} ${SLAVES} &>/dev/null
	msg "Now, Using \"/opt/hadoop-${version}/sbin/start-all.sh\" to start service ..."
}