#! /bin/bash
HOSTNAME=q.vld7net.fr
INNERHOSTNAME=q.paracamplus.com
HOSTPORT=61980
HOSTSSHPORT=61922
DOCKERNAME=vmq
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=false
FW4EX_MASTER_KEY=./fw4excookie.insecure.key

# Share Perl modules with the development machine:
PARACAMPLUSDIR=$HOME/Paracamplus/ExerciseFrameWork
SHARE_FW4EX_PERLLIB=$PARACAMPLUSDIR/perllib
# Don't share this since it will make symbolic links visible to the container:
#SHARE_VAR_WWW=$HOME/Paracamplus/ExerciseFrameWork/Servers/p/Paracamplus-FW4EX-P/root
PROVIDE_APACHE=false
# No need for databas
NEED_POSTGRESQL=false
# 
DEVDIR=$HOME/Paracamplus/ExerciseFrameWork/Servers/q/Paracamplus-FW4EX-Q
ADDITIONAL_FLAGS=" \
  -p 127.0.0.1:${HOSTPORT}:80 "

# end of q.vld7net.fr/config.sh
