#! /bin/bash
# Pack the files pertaining to the server to install.
# If there is a gulpfile.js, run it!

PARACAMPLUSDIR=${PARACAMPLUSDIR:-/missing/Paracamplus}
TGZ=${0%/*}/../RemoteScripts/$MODULE.tgz

NODEVERSION=5.10.0

if [ -f $PARACAMPLUSDIR/$SRCDIR/gulpfile.js ]
then 
    echo "Running gulp..."
    ( cd /usr/local/bin/ 
      if ! [ node-${NODEVERSION} -ef node ] 
      then 
          sudo ln -sf node-${NODEVERSION} ./node 
          sudo npm rebuild node-sass
      fi )
    ( cd $PARACAMPLUSDIR/$SRCDIR/ && gulp dist )
    tar czhf $TGZ --exclude '*~' \
        -C $PARACAMPLUSDIR/$SRCDIR \
        Templates -C dist .
else
    echo "Minifying javascript library files..."
    ( cd $PARACAMPLUSDIR/JQuery ; m )
    tar czhf $TGZ --exclude '*~' \
        -C $PARACAMPLUSDIR/$SRCDIR \
        Templates -C root .
fi

# end of prepare-20-tar-Templates.sh
