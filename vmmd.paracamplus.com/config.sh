#! /bin/bash
HOSTNAME=vmmd.paracamplus.com
HOSTSSHPORT=59022
if docker pull paracamplus/aestxyz_vmmd
then
    DOCKERNAME=vmmd
else
    DOCKERNAME=vmmd1
fi
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
#
ADDITIONAL_FLAGS=" --privileged "
# 
SSHDIR=$(mktemp -d /tmp/ssh-XXXXXX)
LOGDIR=/var/log/fw4ex/md
# end of config.sh
