#! /bin/bash

echo "Generating path.tt from YAML configuration"
TODIR=$ROOTDIR/opt/$HOSTNAME
mkdir -p $TODIR/Templates/doc
mkdir -p $ROOTDIR/var/www/$HOSTNAME

# Generate path.tt
if ! $PARACAMPLUSDIR/Scripts/compilePath.pl --html \
    -i $TODIR/$HOSTNAME.yml \
    -d $PARACAMPLUSDIR/Servers/e/Paracamplus-FW4EX-E/exercisedir/ \
    -o $TODIR/Templates/doc/path.tt
then 
    echo "Cannot generate $TODIR/path.tt"
    exit 13
fi

# Generate JSON too. JSON are also stored on the E server.
PATHDIR=$PARACAMPLUSDIR/Docker/vme/e.paracamplus.com/root.d
PATHDIR=$PATHDIR/opt/e.paracamplus.com/path
if $PARACAMPLUSDIR/Scripts/compilePath.pl --json \
    -i $TODIR/$HOSTNAME.yml \
    -d $PARACAMPLUSDIR/Servers/e/Paracamplus-FW4EX-E/exercisedir/ \
    -o $ROOTDIR/var/www/$HOSTNAME/exercises.json
then 
    SHORTHOSTNAME=${HOSTNAME%.paracamplus.com}
    cp -p $ROOTDIR/var/www/$HOSTNAME/exercises.json $PATHDIR/$SHORTHOSTNAME.json
    cp -p $ROOTDIR/var/www/$HOSTNAME/exercises.json $PATHDIR/$HOSTNAME.json
else
    echo "Cannot generate $ROOTDIR/var/www/$HOSTNAME/exercises.json"
    exit 13
fi

# end of prepare-40-path.sh
