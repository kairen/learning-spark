#!/bin/bash
#
#

source common.sh

function install_jdk {
	ssh $1 sudo apt-get purge openjdk*
	ssh $1 sudo apt-get -y autoremove
	ssh $1 sudo add-apt-repository -y ppa:webupd8team/java
	ssh $1 sudo apt-get update
	ssh $1 echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
	ssh $1 sudo apt-get -y install oracle-java8-installer
}


function install_mesos {
	ssh $2 sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
	ssh $2 DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]'); CODENAME=$(lsb_release -cs); echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
	ssh $2 sudo apt-get update
	
	if [ "$1" == "master" ]; then
		ssh $2 sudo apt-get -y install mesos marathon
	else
		ssh $2 sudo apt-get -y install mesos
	fi
}