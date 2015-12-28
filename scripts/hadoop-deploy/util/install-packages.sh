#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 

function install_jdk {
	cmd $1 "sudo apt-get purge openjdk* &>/dev/null"
	cmd $1 "sudo apt-get -y autoremove &>/dev/null"
	cmd $1 "sudo add-apt-repository -y ppa:webupd8team/java &>/dev/null"
	cmd $1 "sudo apt-get update &>/dev/null"
	AOL=$(echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true")
	echo $AOL | cmd $1 "sudo debconf-set-selections"
	cmd $1 "sudo apt-get -y install oracle-java8-installer &>/dev/null"
}


function install_mesos {
	REPOS=$(echo "deb http://repos.mesosphere.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) main")
	cmd $2 "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF &>/dev/null"
	echo $REPOS | cmd $2 "sudo tee /etc/apt/sources.list.d/mesosphere.list"
	cmd $2 "sudo apt-get update &>/dev/null"
	
	if [ "$1" == "master" ]; then
		cmd $2 "sudo apt-get -y install mesos marathon &>/dev/null"
	else
		cmd $2 "sudo apt-get -y install mesos &>/dev/null"
	fi
}