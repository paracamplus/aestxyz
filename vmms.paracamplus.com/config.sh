#! /bin/bash
HOSTNAME=vmms.paracamplus.com
HOSTSSHPORT=58022
DOCKERNAME=vmms
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# 
SSHDIR=$(mktemp -d /tmp/ssh-XXXXXX)
# The --privileged option is required to set iptables
ADDITIONAL_FLAGS=' --privileged '
# end of config.sh
