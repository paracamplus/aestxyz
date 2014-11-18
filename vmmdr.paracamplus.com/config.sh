#! /bin/bash
HOSTNAME=vmmdr.paracamplus.com
HOSTSSHPORT=61022
DOCKERNAME=vmmdr
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
LOGDIR=/var/log/fw4ex/mdr
PROVIDE_APACHE=false
NEED_FW4EX_MASTER_KEY_DIR=true
SHARE_FW4EX_LOG=true
SSHDIR=$(mktemp -d /tmp/ssh--XXXXXXXX)
PROVIDE_TUNNEL=58022
# end of config.sh
