#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/1/02 Kyle.b Release
# 
function master-install {
	array=("$@")
	arraylength=${#array[@]}
	for (( i=2; i<${arraylength}+1; i++ )); do
   		echo "Processing ${array[$i-1]} "

         ProgressBar 10 30
   		msg "Installing oracle java8 ....."
   		install_jdk ${array[$i-1]} &>/dev/null

         ProgressBar 20 30
   		msg "Installing apache mesos ....."
   		install_mesos "master" ${array[$i-1]} &>/dev/null

         ProgressBar 25 30
   		msg "Configure to mesos-master env ....."
   		master-config ${array[$i-1]} &>/dev/null

          ProgressBar 30 30
   		msg "Finish install ....."
	done
}