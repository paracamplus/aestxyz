#! /bin/bash
HOSTNAME=e.paracamplus.com
HOSTPORT=52080
HOSTSSHPORT=52022
DOCKERNAME=vme
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
ADDITIONAL_FLAGS="-v /opt/$HOSTNAME/exercisedir/:/opt/$HOSTNAME/exercisedir/"
# end of config.sh
