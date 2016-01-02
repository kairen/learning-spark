#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/1/02 Kyle.b Release
# 
function slave-install {
	array=("$@")
	arraylength=${#array[@]}
	MASTER_INDEX=$(index "--masters" ${array[@]})

	if [ -z $MASTER_INDEX ]; then
		msg "${SLAVE_INFO}" "Usage"
		exit 1
	fi

	if [ -z "${array[$MASTER_INDEX]}" ]; then
		msg "${SLAVE_INFO}" "Usage"
		exit 1
	fi

	# Get all master node
	MASTER_IPS=""
	for (( i=MASTER_INDEX+1; i<${arraylength}+1; i++ ));
	do
   		if [ $i == ${arraylength} ]; then
   			MASTER_IPS="${MASTER_IPS}${array[$i-1]}:2181"
   		else
   			MASTER_IPS="${MASTER_IPS}${array[$i-1]}:2181,"
   		fi
	done

	# Get all slave node
	for (( i=2; i<${MASTER_INDEX}; i++ ));
	do
		echo "[ ---------------- ${array[$i-1]} ---------------- ]"
   		msg "Installing oracle java8 ....."
   		run=$(install_jdk ${array[$i-1]})

   		msg "Installing apache mesos ....."
   		run=$(install_mesos "slave" ${array[$i-1]})
   		
   		msg "Configure to mesos-slave env ....."
   		run=$(slave-config ${MASTER_IPS} ${array[$i-1]})
	done
}