#! /bin/bash
# Specific config.sh for a patched vmmd (named vmmda)
# We just change the name of the Docker image to use!
HOSTNAME=vmmd.paracamplus.com
HOSTSSHPORT=59022
DOCKERNAME=vmmda
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
ADDITIONAL_FLAGS=" --privileged "
LOGDIR=/var/log/fw4ex/md
PROVIDE_APACHE=false
NEED_FW4EX_MASTER_KEY_DIR=true
SHARE_FW4EX_LOG=true
SSHDIR=$(mktemp -d /tmp/ssh--XXXXXXXX)
LOGDIR=/var/log/fw4ex/md
# end of config.sh
