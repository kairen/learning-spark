#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release

# Configure zookeeper
# 

ssh $1 echo 1 | sudo tee /etc/zookeeper/conf/myid
ssh $1 echo server.1=$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2888:3888 | sudo tee -a /etc/zookeeper/conf/zoo.cfg
ssh $1 sudo service zookeeper restart

# Configure mesos-master
ssh $1 echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/mesos | sudo tee /etc/mesos/zk
ssh $1 echo 1 | sudo tee /etc/mesos-master/quorum
ssh $1 echo $(ip route get 8.8.8.8 | awk '{print $NF; exit}') | sudo tee /etc/mesos-master/ip
ssh $1 echo 'mesos-cluster' | sudo tee /etc/mesos-master/cluster
ssh $1 echo $(ip route get 8.8.8.8 | awk '{print $NF; exit}') | sudo tee /etc/mesos-master/advertise_ip

# Configure marathon
ssh $1 sudo mkdir /etc/marathon/
ssh $1 sudo mkdir /etc/marathon/conf
ssh $1 echo $(ip route get 8.8.8.8 | awk '{print $NF; exit}') | sudo tee /etc/marathon/conf/hostname
ssh $1 echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/mesos | sudo tee /etc/marathon/conf/master
ssh $1 echo zk://$(ip route get 8.8.8.8 | awk '{print $NF; exit}'):2181/marathon | sudo tee /etc/marathon/conf/zk
ssh $1 sudo service mesos-slave stop
ssh $1 sudo sh -c "echo manual > /etc/init/mesos-slave.override"
ssh $1 sudo service mesos-master restart
ssh $1 sudo service marathon restart
