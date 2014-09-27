#! /bin/bash

PARACAMPLUSDIR=${PARACAMPLUSDIR:-/missing/Paracamplus}

TODIR=$ROOTDIR/var/www/$HOSTNAME/
mkdir -p $TODIR
rsync -avu $PARACAMPLUSDIR/Servers/s/root/*.txt $TODIR/

patchTXTfile $TODIR/index.txt

# end of prepare-S-30.sh
