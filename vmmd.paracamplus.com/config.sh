#! /bin/bash
HOSTNAME=vmmd.paracamplus.com
HOSTSSHPORT=59022
if docker images | grep -q 'paracamplus/aestxyz_vmmd '
then
    DOCKERNAME=vmmd
else
    DOCKERNAME=vmmd1
fi
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
#
ADDITIONAL_FLAGS=" --privileged "
# 
LOGDIR=/var/log/fw4ex/md
PROVIDE_APACHE=false
NEED_FW4EX_MASTER_KEY_DIR=true
SHARE_FW4EX_LOG=true
SSHDIR=$(mktemp -d /tmp/ssh--XXXXXXXX)
LOGDIR=/var/log/fw4ex/md
# end of config.sh
