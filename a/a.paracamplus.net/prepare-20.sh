#! /bin/bash
# Pack the files pertaining to the server to install:

PARACAMPLUSDIR=${PARACAMPLUSDIR:-/missing/Paracamplus}

echo "Minifying javascript library files..."
( cd $PARACAMPLUSDIR/JQuery ; m )

TGZ=${0%/*}/../RemoteScripts/$MODULE.tgz
tar czhf $TGZ --exclude '*~' \
    -C $PARACAMPLUSDIR/$SRCDIR \
    Templates -C root .

# end of prepare-20.sh
