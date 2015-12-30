#!/bin/bash
# Program:
#       This program is install mesos.
# History:
# 2015/12/21 Kyle.b Release
# 
MASTER_INFO="
mesos-deploy master-install {host1, host2, hosts}      # installing a master node
"

SLAVE_INFO="
mesos-deploy slave-install {host1, host2, hosts}       # installing some slaves node
  Arguments: --masters {master1, master2, masters}     # add some masters to slaves 
"