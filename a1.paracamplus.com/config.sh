#! /bin/bash
HOSTNAME=a1.paracamplus.com
INNERHOSTNAME=a.paracamplus.com
HOSTPORT=51080
HOSTSSHPORT=51022
DOCKERNAME=vma
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# So we may persist jobdir, batchdir
mkdir -p /opt/$HOSTNAME/jobdir
ADDITIONAL_FLAGS="-v /opt/$HOSTNAME/jobdir/:/opt/$INNERHOSTNAME/jobdir/ "
mkdir -p /opt/$HOSTNAME/batchdir
ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v /opt/$HOSTNAME/batchdir/:/opt/$INNERHOSTNAME/batchdir/ "
# end of config.sh
