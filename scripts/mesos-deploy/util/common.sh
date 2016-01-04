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

function cmd {
   ssh -o StrictHostKeyChecking=no $1 $2
}

function ProgressBar {
  let _progress=(${1}*100/${2}*100)/100
  let _done=(${_progress}*4)/10
  let _left=40-$_done

  _start=1
  _end=100

  _fill=$(printf "%${_done}s")
  _empty=$(printf "%${_left}s")
  # _info=$(printf "${3}")

  printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%% "
}
