#! /bin/bash

echo "Generating path.tt from YAML configuration"
TODIR=$ROOTDIR/opt/$HOSTNAME
mkdir -p $TODIR/Templates/doc
if ! $PARACAMPLUSDIR/Scripts/compilePath.pl --html \
    -i $TODIR/$HOSTNAME.yml \
    -d $PARACAMPLUSDIR/Servers/e/Paracamplus-FW4EX-E/exercisedir/ \
    -o $TODIR/Templates/doc/path.tt
then 
    echo "Cannot generate $TODIR/path.tt"
    exit 13
fi

# end of prepare-40-path.sh
