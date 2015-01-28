#! /bin/bash
HOSTNAME=a.paracamplus.com
HOSTPORT=51080
HOSTSSHPORT=51022
DOCKERNAME=vma
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# So we may persist jobdir, batchdir
mkdir -p /opt/$HOSTNAME/jobdir
ADDITIONAL_FLAGS="-v /opt/$HOSTNAME/jobdir/:/opt/$HOSTNAME/jobdir/ "
mkdir -p /opt/$HOSTNAME/batchdir
ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v /opt/$HOSTNAME/batchdir/:/opt/$HOSTNAME/batchdir/ "
# end of config.sh
