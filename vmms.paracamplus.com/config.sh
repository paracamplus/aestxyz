#! /bin/bash
HOSTNAME=vmms.paracamplus.com
HOSTSSHPORT=58022
DOCKERNAME=vmms
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# 
SSHDIR=$(mktemp -d /tmp/ssh-XXXXXX)
# The --privileged option is required to set iptables
ADDITIONAL_FLAGS=' --privileged '
LOGDIR=/var/log/fw4ex/ms
PROVIDE_APACHE=false
NEED_FW4EX_MASTER_KEY_DIR=false
# end of config.sh
