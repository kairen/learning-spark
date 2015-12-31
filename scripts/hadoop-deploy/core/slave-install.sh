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
      if [ "${array[$i-1]}" != "--master" ] && [ "${array[$i-1]}" != "--version" ]; then
        msg "Option: \"${array[$i-1]}\" not a valid  option ..." "ERROR"
        exit 1
      fi
    fi
  done
}

function slave-install {
	array=("$@")
	arraylength=${#array[@]}

	check_para $@

	MASTER_INDEX=$(index "--master" ${array[@]})
	VERSION_INDEX=$(index "--version" ${array[@]})

	MASTER=""
	if [ $MASTER_INDEX -gt 0 ]; then
		ARGS="${array[$MASTER_INDEX]}"
		if [ "$ARGS" != "" ]; then
			MASTER=${array[$MASTER_INDEX]}
		else
			msg "Option: --master value error ..." "ERROR"
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

	local version=${VERSION:-"2.6.0"}
	local master=${MASTER}
	
	begin=$(max $MASTER_INDEX $VERSION_INDEX)

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
   		hadoop-env-config ${version} ${array[$i-1]} ${master} &>/dev/nullｓ

   		ProgressBar 25 25
   		msg "Install Finish ...."

   		SLAVES="$SLAVES${array[$i-1]}\n"
	done

	hadoop-slave-config ${version} ${master} ${SLAVES} &>/dev/null
	msg "Now, Using \"/opt/hadoop-${version}/sbin/start-all.sh\" to start service ..."
   	msg "Then, Using \"source ~/.bashrc\" to source env ..."
   		
}