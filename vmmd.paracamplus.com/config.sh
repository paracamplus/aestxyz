#! /bin/bash
HOSTNAME=vmmd.paracamplus.com
HOSTSSHPORT=59022
DOCKERNAME=vmmd
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
#
ADDITIONAL_FLAGS="-d --privileged"
# 
SSHDIR=$(mktemp -d /tmp/ssh-XXXXXX)
LOGDIR=/var/log/fw4ex/md
# end of config.sh
