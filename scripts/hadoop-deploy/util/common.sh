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

# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
function ProgressBar {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%  "

}

# Variables
_start=1

# This accounts as the "totalState" variable for the ProgressBar function
_end=100

# # Proof of concept
# for number in $(seq ${_start} ${_end})
# do
#     sleep 0.1
#     ProgressBar ${number} ${_end}
# done
# printf '\nFinished!\n'
