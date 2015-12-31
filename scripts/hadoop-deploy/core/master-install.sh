#!/bin/bash
# Program:
#       This program is install hadoop.
# History:
# 2015/12/27 Kyle.b Release
# 
function check_para {
  array=("$@")
  arraylength=${#array[@]}

  for (( i=1; i<${arraylength}+1; i++ )); do
    if echo ${array[$i-1]} | grep -q "\-\-" ; then
      if [ "${array[$i-1]}" != "--spark" ] && [ "${array[$i-1]}" != "--version" ]; then
        msg "Option: \"${array[$i-1]}\" not a valid  option ..." "ERROR"
        exit 1
      fi
    fi
  done
}

function master-install {
	array=("$@")
	arraylength=${#array[@]}

	check_para $@
	
	SPARK_INDEX=$(index "--spark" ${array[@]})
	VERSION_INDEX=$(index "--version" ${array[@]})

	SPARK=""
	if [ $SPARK_INDEX -gt 0 ]; then
		ARGS="${array[$SPARK_INDEX]}"
		if [ "$ARGS" != "" ] && ([ "$ARGS" == "true" ] || [ "$ARGS" == "false" ]); then
			SPARK=${array[$SPARK_INDEX]}
		else
			msg "Option: --spark value error ..." "ERROR"
			exit 1
		fi
	fi

	VERSION=""
	if [ $VERSION_INDEX -gt 0 ]; then
		ARGS="${array[$VERSION_INDEX]}"
		if [ "$ARGS" != "" ] && echo $ARGS | grep -q "[0-9].[0-9].[0-9]" ; then
			VERSION=${array[$VERSION_INDEX]}
		else
			msg "Option: --version value error ..." "ERROR"
			exit 1
		fi
	fi

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