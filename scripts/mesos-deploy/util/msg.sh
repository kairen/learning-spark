#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 
MASTER_INFO="
mesos-deploy master-install {host1, ...}             # installing a master node
"

SLAVE_INFO="
mesos-deploy slave-install {host1, ...} [options]    # installing some slaves node
Options:
        --masters {master1, ...}                     # add some masters to slaves 
"