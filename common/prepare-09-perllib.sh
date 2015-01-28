#! /bin/bash
# Pack the whole Paracamplus Perl library.
# There are some Catalyst plugins to be packed as well.

tar czf ${0%/*}/../RemoteScripts/perllib.tgz \
    -C $PARACAMPLUSDIR/perllib \
    $( cd $PARACAMPLUSDIR/perllib/ && \
       find Paracamplus Catalyst -name '*.pm' )

# end of prepare-09-perllib.sh
