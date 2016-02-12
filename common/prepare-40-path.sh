#! /bin/bash

echo "Generating path.tt from YAML configuration"
TODIR=$ROOTDIR/opt/$HOSTNAME
mkdir -p $TODIR/Templates/doc
mkdir -p $ROOTDIR/var/www/$HOSTNAME

# Generate path.tt
trap "rm /tmp/cp.log" 0
if $PARACAMPLUSDIR/Scripts/compilePath.pl --html \
    -i $TODIR/$HOSTNAME.yml \
    -d $PARACAMPLUSDIR/Servers/e/Paracamplus-FW4EX-E/exercisedir/ \
    -o $TODIR/Templates/doc/path.tt 2>&1 | tee /tmp/cp.log
then 
    if grep 'YAML Warning' < /tmp/cp.log
    then
        cat /tmp/cp.log
        exit 13
    fi
else
    echo "Cannot generate $TODIR/path.tt"
    exit 13
fi

# Generate JSON too. JSON are also stored on the E server.
PATHDIR=$PARACAMPLUSDIR/Docker/vme/e.paracamplus.com/root.d
PATHDIR=$PATHDIR/opt/e.paracamplus.com/path
mkdir -p $PATHDIR
JSON=$ROOTDIR/var/www/$HOSTNAME/exercises.json
if $PARACAMPLUSDIR/Scripts/compilePath.pl --json \
    -i $TODIR/$HOSTNAME.yml \
    -d $PARACAMPLUSDIR/Servers/e/Paracamplus-FW4EX-E/exercisedir/ \
    -o $JSON
then 
    SHORTHOSTNAME=${HOSTNAME%.paracamplus.com}
    cp -p $JSON $PATHDIR/$SHORTHOSTNAME.json
    cp -p $JSON $PATHDIR/$HOSTNAME.json
    cp -p $JSON $PARACAMPLUSDIR/Servers/e/path/$HOSTNAME.json
    cp -p $JSON $PARACAMPLUSDIR/Servers/e/path/$SHORTHOSTNAME.json
else
    echo "Cannot generate $ROOTDIR/var/www/$HOSTNAME/exercises.json"
    exit 13
fi

# end of prepare-40-path.sh
