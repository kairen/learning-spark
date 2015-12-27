#!/bin/bash
#
#

function install_jdk {
	ssh $1 sudo apt-get purge openjdk*
	ssh $1 sudo apt-get -y autoremove
	ssh $1 sudo add-apt-repository -y ppa:webupd8team/java
	ssh $1 sudo apt-get update
	ssh $1 echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	ssh $1 echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	ssh $1 sudo apt-get -y install oracle-java8-installer
}


function install_mesos {
	ssh $1 sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
	ssh $1 DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]'); CODENAME=$(lsb_release -cs); echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
	ssh $1 sudo apt-get update
	if [ "$2" == "master" ]; then
		ssh $1 sudo apt-get -y install mesos marathon
	else
		ssh $1 sudo apt-get -y install mesos
	fi
}