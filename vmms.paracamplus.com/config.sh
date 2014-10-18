#! /bin/bash
HOSTNAME=vmms.paracamplus.com
HOSTSSHPORT=58022
DOCKERNAME=vmms
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# 
SSHDIR=$(mktemp -d /tmp/ssh-XXXXXX)
# end of config.sh
