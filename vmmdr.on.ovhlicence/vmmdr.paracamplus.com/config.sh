#! /bin/bash
# Specific configuration of vmmdr+vmms to be run on a remote machine.

# BASEDIR is the directory holding monitor.sh
# BASEDIR has two subdirectories, vmm{dr,s}.paracamplus.com/
BASEDIR=$(pwd)/

HOSTSSHPORT=61022
DOCKERNAME=vmmdr
HOSTNAME=${DOCKERNAME}.paracamplus.com
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}

PROVIDE_APACHE=false
SHARE_FW4EX_LOG=true
PROVIDE_TUNNEL=58022

# LOGDIR must be writable by the user running the containers.
# This directory will hold root-owned log files.
LOGDIR=$BASEDIR/log.d
mkdir -p $LOGDIR/md/

# In this directory will be stored the needed required keys.
# It will be mapped onto /root/.ssh/
SSHDIR=$BASEDIR/ssh.d
mkdir -p $SSHDIR/

# Where will be fw4excookie.insecure.key 
# It will be mapped onto /opt/$HOSTNAME/private/
# NOTA: the fw4excookie.insecure.key is now stored in SSHDIR/
NEED_FW4EX_MASTER_KEY_DIR=false
NEED_FW4EX_MASTER_KEY=true
FW4EX_MASTER_KEY=$BASEDIR/fw4excookie.insecure.key

# end of config.sh
