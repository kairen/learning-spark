#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 

function install_jdk {
	ssh $1 sudo apt-get purge openjdk* &>/dev/null
	ssh $1 sudo apt-get -y autoremove &>/dev/null
	ssh $1 sudo add-apt-repository -y ppa:webupd8team/java &>/dev/null
	ssh $1 sudo apt-get update &>/dev/null
	AOL=$(echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true")
	echo $AOL | ssh $1 sudo debconf-set-selections
	ssh $1 sudo apt-get -y install oracle-java8-installer &>/dev/null
}


function install_mesos {
	REPOS=$(echo "deb http://repos.mesosphere.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) main")
	ssh $2 sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF &>/dev/null
	echo $REPOS | ssh $2 sudo tee /etc/apt/sources.list.d/mesosphere.list
	ssh $2 sudo apt-get update &>/dev/null
	
	if [ "$1" == "master" ]; then
		ssh $2 sudo apt-get -y install mesos marathon &>/dev/null
	else
		ssh $2 sudo apt-get -y install mesos &>/dev/null
	fi
}