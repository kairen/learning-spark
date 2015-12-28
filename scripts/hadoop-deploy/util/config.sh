#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 
function ssh-config {
	scp conf/expect.sh $1:~/
	cmd $1 "sh expect.sh"
	cmd $1 "rm -rf expect.sh"
}