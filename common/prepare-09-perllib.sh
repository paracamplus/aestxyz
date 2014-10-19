#! /bin/bash

tar czf ${0%/*}/../RemoteScripts/perllib.tgz \
    -C $PARACAMPLUSDIR/perllib \
    $( cd $PARACAMPLUSDIR/perllib/ && find Paracamplus -name '*.pm' )

# end of prepare-09-perllib.sh
