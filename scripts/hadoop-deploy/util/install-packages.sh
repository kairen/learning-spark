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

function install_other {
	cmd $1 "sudo apt-get install -y expect &>/dev/null"
}

function install_hadoop {
	URL="http://files.imaclouds.com/packages/hadoop/hadoop-${1}.tar.gz"
	cmd $2 "curl -s qsub $URL | sudo tar -xz -C /opt/"
}