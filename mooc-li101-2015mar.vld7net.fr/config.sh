#! /bin/bash
HOSTNAME=mooc-li101-2015mar.vld7net.fr
HOSTPORT=63080
HOSTSSHPORT=63022
DOCKERNAME=mooc-li101-2015mar
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# special for bijou:
SSHDIR=/tmp/${HOSTNAME}/ssh.d
FW4EX_MASTER_KEY=/opt/common-paracamplus.com/fw4excookie.insecure.key
LOGDIR=/tmp/${HOSTNAME}/log.d
SHARE_FW4EX_LOG=true
# end of mooc-li101-2015mar.vld7net.fr/config.sh
