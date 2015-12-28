#!/bin/bash
#
# Emits a string to console (poor man's log)
# with an optional log level (can be anything, will be prepended to the message)
#
# usage: msg 'msg' [level]
# 
function msg {
    local level=${2:-"INFO"}
    echo "[$level] $1"
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
  for (( i=2; i<${arraylength}+1; i++ ));do
   		if [ "$1" == "${array[$i-1]}" ]; then
   			echo "$i"
   			exit 1
   		fi
	done
  echo "0"
}

function cmd {
   ssh -o StrictHostKeyChecking=no $1 $2
}

function max {
  ar=($@)
  IFS=$'\n'
  echo "${ar[*]}" | sort -nr | head -n1
}
