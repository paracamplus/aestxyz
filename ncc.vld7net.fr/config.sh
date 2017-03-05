#! /bin/bash
HOSTNAME=ncc.vld7net.fr
INNERHOSTNAME=cc.paracamplus.com
HOSTPORT=64280
HOSTSSHPORT=64222
DOCKERNAME=ncc
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}
FW4EX_MASTER_KEY=./fw4excookie.insecure.key

# Share Perl modules with the development machine:
PARACAMPLUSDIR=$HOME/Paracamplus/ExerciseFrameWork
SHARE_FW4EX_PERLLIB=$PARACAMPLUSDIR/perllib

# connect to local test database:
NEED_POSTGRESQL=false
PROVIDE_APACHE=false
PROVIDE_SMTP=false

# Get rid of symbolic links
DEVDIR=$HOME/Paracamplus/ExerciseFrameWork/Servers/w.ncc/Paracamplus-FW4EX-CC
DOCKERDIR=$HOME/Paracamplus/ExerciseFrameWork/Docker
ADDITIONAL_FLAGS="-v /home/queinnec:/home/queinnec \
  -v $DEVDIR/dist:/var/www/$INNERHOSTNAME \
  -p 127.0.0.1:${HOSTPORT}:80 "

# end of ncc.vld7net.fr/config.sh
