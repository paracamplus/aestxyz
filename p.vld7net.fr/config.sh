#! /bin/bash
HOSTNAME=p.vld7net.fr
INNERHOSTNAME=p.paracamplus.com
HOSTPORT=61980
HOSTSSHPORT=61922
DOCKERNAME=vmp
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=false
FW4EX_MASTER_KEY=./fw4excookie.insecure.key

# Share Perl modules with the development machine:
PARACAMPLUSDIR=$HOME/Paracamplus/ExerciseFrameWork
SHARE_FW4EX_PERLLIB=$PARACAMPLUSDIR/perllib
# Don't share this since it will make symbolic links visible to the container:
#SHARE_VAR_WWW=$HOME/Paracamplus/ExerciseFrameWork/Servers/p/Paracamplus-FW4EX-P/root
PROVIDE_APACHE=false
# Give access to the postgres db running on bijou:
#NEED_POSTGRESQL=true
#DBHOST=docker
PROVIDE_TUNNEL=5432
# 
DEVDIR=$HOME/Paracamplus/ExerciseFrameWork/Servers/p/Paracamplus-FW4EX-P
ADDITIONAL_FLAGS="-v /home/queinnec:/home/queinnec \
  -v $DEVDIR/dist:/var/www/$INNERHOSTNAME \
  -v $DEVDIR/Templates:/opt/$INNERHOSTNAME/Templates \
  -p 127.0.0.1:${HOSTPORT}:80 "

# On Mac: boot2docker 10.0.2.15 eth0
#                     192.168.59.103 eth1   (ports 22 2375)
#                     172.17.42.1 docker0
# vmp.vld7net.fr      172.17.0.*
# dans boot2docker-vm nettoyer /var/log/docker.log

# end of p.vld7net.fr/config.sh
