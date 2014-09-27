#! /bin/bash
# Copy private and public keys (from the A server)

TODIR=${ROOTDIR:-/missing/root.d}/opt/$HOSTNAME
mkdir -p $TODIR
(
    FROM=${0%/*}/../../a/a.${HOSTNAME#e.}/root.d/opt/a.${HOSTNAME#e.}
    cp -p $FROM/*.key $TODIR/
)

# end of prepare-11.sh
