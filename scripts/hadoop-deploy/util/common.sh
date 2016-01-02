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

function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    _start=1
    _end=100

    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%  "
}

CHECK_OPTIONS=()

function check_options {
  array=("$@")
  arraylength=${#array[@]}

  for (( i=1; i<${arraylength}+1; i++ )); do
    if echo ${array[$i-1]} | grep -q "\-\-" ; then
      flag=false
      for check_option in ${CHECK_OPTIONS[@]}; do
        if [ "${check_option}" == "${array[$i-1]}" ]; then 
            flag=true
        fi
      done
      if [ "$flag" == "false" ]; then
          msg "Option: ${array[$i-1]} not a valid option ..." "ERROR"
          exit 1
      fi
    fi
  done

}

RETURE_VALUE=""

function check_value {
  INDEX=${1}
  VALUE=${2}
  OPTION=${3}

  if [ ${INDEX} -gt 0 ]; then
    if [ "${VALUE}" == "" ]; then
      msg "The ${OPTION} option value error ..." "ERROR"
      exit 1
    else
      RETURE_VALUE=${VALUE}
    fi
  fi
}

function check_bool {
  INDEX=${1}
  VALUE=${2}
  OPTION=${3}

  if [ ${INDEX} -gt 0 ]; then
    if [ "${VALUE}" == "" ] || ([ "${VALUE}" != "true" ] && [ "${VALUE}" != "false" ]); then
      msg "The ${OPTION} option value error ..." "ERROR"
      exit 1
    else
      RETURE_VALUE=${VALUE}
    fi
  fi
}

function check_pattern {
  INDEX=${1}
  PATTERN=${2}
  VALUE=${3}
  OPTION=${4}

  if [ ${INDEX} -gt 0 ]; then
    if [ "${VALUE}" != "" ] && echo ${VALUE} | grep -q "${PATTERN}" ; then
      RETURE_VALUE=${VALUE}
    else
      msg "The ${OPTION} option value error ..." "ERROR"
      exit 1
    fi
  fi
}