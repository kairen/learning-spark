#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 
MASTER_INFO="
hadoop-deploy master-install [options] {host1, ...}   # Install a master node and all-in-one hadoop node

Options:
        --spark {true}                                # Install spark to node,  default is false
        --hbase {false}                               # Install hbase to node, default is false
        --hive {false}                                # Install hive to node, default is false
        --version {2.6.0}                             # Install version, default is 2.6.0
        --spark-version {1.5.2}                       # Install spark version, default is 1.5.2
        --ignore {false}                              # Ignore install step, default is false
"

SLAVE_INFO="
hadoop-deploy slave-install [options] {host1, ...}    # Install some slaves node

Options:
        --hbase {false}                               # Install hbase to node, default is false
        --master {master}                             # Add some master to slaves 
        --version {2.6.0}                             # Install version, default is 2.6.0
        --ignore {false}                              # Ignore install step, default is false

"

SPARK_MESSAGE="
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ \`/ __/  \'_/
   /___/ .__/\_,_/_/ /_/\_\   POWER BY KYLE BAI
      /_/                     
"