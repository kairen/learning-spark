#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 

function master-config {
	# Configure zookeeper
	cmd $1 "echo 1 | sudo tee /etc/zookeeper/conf/myid"
	cmd $1 "echo server.1=$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2888:3888 | sudo tee -a /etc/zookeeper/conf/zoo.cfg"
	cmd $1 "sudo service zookeeper restart &>/dev/null"

	# Configure mesos-master
	cmd $1 "echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/mesos | sudo tee /etc/mesos/zk"
	cmd $1 "echo 1 | sudo tee /etc/mesos-master/quorum"
	cmd $1 "echo $(ip route get 8.8.8.8 | awk '{print $NF; exit}') | sudo tee /etc/mesos-master/ip"
	cmd $1 "echo 'mesos-cluster' | sudo tee /etc/mesos-master/cluster"
	cmd $1 "echo $(ip route get 8.8.8.8 | awk '{print $NF; exit}') | sudo tee /etc/mesos-master/advertise_ip"

	# Configure marathon
	cmd $1 "sudo mkdir /etc/marathon/"
	cmd $1 "sudo mkdir /etc/marathon/conf"
	echo $1 | cmd $1 "sudo tee /etc/marathon/conf/hostname"
	cmd $1 "echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/mesos | sudo tee /etc/marathon/conf/master"
	cmd $1 "echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/marathon | sudo tee /etc/marathon/conf/zk"
	
	cmd $1 "sudo service mesos-slave stop &>/dev/null"
	echo manual | cmd $1 "sudo tee /etc/init/mesos-slave.override"

	cmd $1 "sudo service mesos-master restart &>/dev/null"
	cmd $1 "sudo service marathon restart &>/dev/null"
}

function slave-config {
	# Configure zookeeper
	echo manual | cmd $2 "sudo tee /etc/init/zookeeper.override"
	cmd $2 "sudo service zookeeper stop &>/dev/null"
	
	# Configure mesos-slave
	echo "zk://$1/mesos" | cmd $2 "sudo tee /etc/mesos/zk"
	echo $2 | cmd $2 "sudo tee /etc/mesos-slave/ip"
	echo $2 | cmd $2 "sudo tee /etc/mesos-slave/hostname"
	cmd $2 "sudo service mesos-master stop &>/dev/null"

	echo manual | cmd $2 "sudo tee /etc/init/mesos-master.override"
	cmd $2 "sudo service mesos-slave restart &>/dev/null"
}

