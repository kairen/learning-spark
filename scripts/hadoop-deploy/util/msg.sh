#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 
MASTER_INFO="
hadoop-deploy master-install {host1, host2, hosts}     # Install a master node and all-in-one hadoop node
              --spark {true}                           # Install spark to node, the default is false
              --version {2.6.0}                        # Install version, the default is 2.6.0
"

SLAVE_INFO="
hadoop-deploy slave-install {host1, host2, hosts}      # Install some slaves node
              --master {master}                        # Add some master to slaves 
              --version {2.6.0}                        # Install version, the default is 2.6.0
"

SPARK_MESSAGE="
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ \`/ __/  \'_/
   /___/ .__/\_,_/_/ /_/\_\   POWER BY KYLE BAI
      /_/                     
"