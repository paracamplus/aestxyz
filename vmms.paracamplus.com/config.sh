#! /bin/bash
# Specific configuration of vmms

# BASEDIR is the directory holding monitor.sh
# BASEDIR has two subdirectories, vmm{dr,s}.paracamplus.com/
BASEDIR=$(pwd)/

HOSTSSHPORT=58022
DOCKERNAME=vmms
HOSTNAME=${DOCKERNAME}.paracamplus.com
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}

PROVIDE_APACHE=false
SHARE_FW4EX_LOG=true
# --privileged is needed in order to set iptables within the container:
ADDITIONAL_FLAGS=' --privileged '

# LOGDIR must be writable by the user running the containers.
# This directory will hold root-owned log files.
LOGDIR=$BASEDIR/log.d
mkdir -p $LOGDIR/ms/

# In this directory will be stored the needed required keys.
# It will be mapped onto /root/.ssh/
SSHDIR=$BASEDIR/ssh.d
mkdir -p $SSHDIR/

# No need for fw4excookie.insecure.key 
NEED_FW4EX_MASTER_KEY_DIR=false
NEED_FW4EX_MASTER_KEY=false

# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of config.sh
