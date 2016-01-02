#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/1/02 Kyle.b Release
# 
function master-install {
	array=("$@")
	arraylength=${#array[@]}
	for (( i=2; i<${arraylength}+1; i++ ));
	do
   		echo "[ ---------------- ${array[$i-1]} ---------------- ]"
   		msg "Installing oracle java8 ....."
   		run=$(install_jdk ${array[$i-1]})

   		msg "Installing apache mesos ....."
   		run=$(install_mesos "master" ${array[$i-1]})

   		msg "Configure to mesos-master env ....."
   		run=$(master-config ${array[$i-1]})

   		msg "Finish install ....."
	done
}