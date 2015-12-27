#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 

source common.sh
source install-packages.sh


function master-install {
	msg "Install master node ..." 
	array=("$@")
	arraylength=${#array[@]}
	for (( i=2; i<${arraylength}+1; i++ ));
	do
   		echo "${array[$i-1]}"
	done
}

function slave-install {
	msg "Install slaves node ..." 
}

if [ "$1" == "master-install" ]; then
	if [ -z "$2" ]; then
		msg "${MASTER_INFO}" "master-install Usage"
	else
		master-install $@
	fi
elif [[ "$1" == "slave-install" ]]; then
	msg "${SLAVE_INFO}" "slave-install Usage"

else
	msg "${MASTER_INFO} ${SLAVE_INFO}" "Usage"
fi


