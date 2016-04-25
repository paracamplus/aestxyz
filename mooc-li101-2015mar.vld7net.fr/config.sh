#! /bin/bash
HOSTNAME=mooc-li101-2015mar.vld7net.fr
INNERHOSTNAME=mooc-li101-2015mar.paracamplus.com
HOSTPORT=63080
HOSTSSHPORT=63022
DOCKERNAME=mooc-li101-2015mar
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=false
PROVIDE_APACHE=false
# special for bijou:
REFRESH_DOCKER_IMAGES=false
SSHDIR=/tmp/Docker/${HOSTNAME}/ssh.d
FW4EX_MASTER_KEY=/opt/common-paracamplus.com/fw4excookie.insecure.key
LOGDIR=/tmp/Docker/${HOSTNAME}/log.d
SHARE_FW4EX_LOG=true
#SHARE_FW4EX_PERLLIB=$HOME/Paracamplus/ExerciseFrameWork/perllib
#ADDITIONAL_FLAGS="-v $HOME/Paracamplus/ExerciseFrameWork/Servers/GenericApp/Templates:/opt/$INNERHOSTNAME/Templates/Default"
# end of mooc-li101-2015mar.vld7net.fr/config.sh
