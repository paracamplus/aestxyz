#! /bin/bash
# Pack the paths

tar czf ${0%/*}/../RemoteScripts/path.tgz \
    -C $PARACAMPLUSDIR/Servers/e/path \
    $( cd $PARACAMPLUSDIR/Servers/e/path/ && \
       ls -1 *.xml *.json )

# end of prepare-19-path.sh
