#! /bin/bash
HOSTNAME=e1.paracamplus.com
INNERHOSTNAME=e.paracamplus.com
HOSTPORT=52080
HOSTSSHPORT=52022
DOCKERNAME=vme
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}
# Persist exercises on the Docker host:
mkdir -p /opt/$HOSTNAME/exercisedir
ADDITIONAL_FLAGS="-v /opt/$HOSTNAME/exercisedir/:/opt/$INNERHOSTNAME/exercisedir/"
# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of config.sh
