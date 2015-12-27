#!/bin/bash
#
# Emits a string to console (poor man's log)
# with an optional log level (can be anything, will be prepended to the message)
#
# usage: msg 'msg' [level]

function msg {
    local level=${2:-"INFO"}
    echo "[$level] $1"
}

# Emits an Error message
#
# usage: error "Something went wrong"
function error {
    msg $1 "ERROR"
}

# Wraps a command and exits if it fails
#
# usage: wrap cat /tmp/foo/bar
function wrap {
    local CMD="$@"
    $@
    if [[ $? != 0 ]]; then
        error "Failed: $CMD"
        exit 1
    fi
}

function index {
	array=$2
	arraylength=${#array[@]}
  	for (( i=2; i<${arraylength}+1; i++ ));
	do
   		if [ "$1" == "${array[$i-1]}" ]; then
   			echo "$i"
   			break
   		fi
	done
}

MASTER_INFO="
mesos-deploy master-install {host1, host2, hosts}   # installing a master node
"

SLAVE_INFO="
mesos-deploy slave-install {host1, host2, hosts}    # installing some slaves node
  Arguments: --masters {master1, master2, masters}     # add some masters to slaves 
"
