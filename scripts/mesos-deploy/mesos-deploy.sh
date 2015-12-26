#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
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