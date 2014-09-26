#! /bin/bash
# Prepare the Docker build process on the Docker host.
# This script is supposed to be run in the Docker/ directory.
# Errors are signalled with a 1x code.

# The structure of the directory (say a/) where the Dockerfile stays
# is as follows: 
#    a/Dockerfile
#    a/HOSTNAME/HOSTNAME.sh              configuration
#    a/HOSTNAME/scripts.sh               to be run on the Docker host
#    a/HOSTNAME/root.d/                  to be copied into the container
#    a/RemoteScripts/scripts.sh          to be run in the container

# Determine the name of the server to install in the container:
export HOSTNAME="$(cd ${0%/*} ; pwd)"
HOSTNAME=${HOSTNAME##*/}
# HOSTNAME may be something like a.paracamplus.net

# Source the common variables that depend on the development machine:
source ${0%/*}/../../common/local.sh
# Source the configuration variables for that server:
source ${0%/*}/$HOSTNAME.sh
# Source some utilities:
source ${0%/*}/../../common/preparelib.sh

# The top directory of files to be copied in the Docker container:
ROOTDIR=${0%/*}/root.d

# Get the version number from Mercurial:
VERSION=`echo $( cd $PARACAMPLUSDIR/ && \
   hg heads | awk -F: '/^changeset:/ {print $2;nextfile}' )`
export VERSION=$VERSION
echo "Current servers' VERSION is $VERSION"

# Generate Apache configuration:
TODIR=$ROOTDIR/etc/apache2/sites-available
mkdir -p $TODIR
if [ -r $TODIR/$HOSTNAME ]
then
    echo "Keeping current Apache configuration"
else
    echo "Generating missing Apache configuration"
    $PARACAMPLUSDIR/Scripts/compilePath.pl --apache \
        --servername $HOSTNAME \
        --perlmodule Paracamplus-FW4EX-$MODULE \
        --version "$VERSION" \
        -o $TODIR/$HOSTNAME
fi

# Generating Catalyst Controller
SanitizedHOSTNAME=${HOSTNAME//./_}
SanitizedHOSTNAME=${SanitizedHOSTNAME//-/_}
TODIR=$ROOTDIR/usr/local/lib/site_perl/Paracamplus/FW4EX/${MODULE}
mkdir -p $TODIR
if [ -r $TODIR/$SanitizedHOSTNAME.pm ]
then
    echo "Keeping current Catalyst controller $SanitizedHOSTNAME.pm"
else
    echo "Generating missing Catalyst controller $SanitizedHOSTNAME.pm"
    $PARACAMPLUSDIR/Scripts/compilePath.pl --perl \
        --servername $HOSTNAME \
        --perlmodule Paracamplus-FW4EX-$MODULE \
        --version "$VERSION" \
        -o $TODIR/${SanitizedHOSTNAME}.pm
fi
cp $PARACAMPLUSDIR/perllib/Paracamplus/FW4EX/${MODULE}.pm $TODIR.pm
patchPerlfile $TODIR.pm

# Checking Catalyst YAML configuration
TODIR=$ROOTDIR/opt/$HOSTNAME
mkdir -p $TODIR
echo $VERSION > $TODIR/VERSION.txt
if [ -r $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml ]
then 
    if $PARACAMPLUSDIR/Scripts/checkYAML.pl \
        $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml
    then 
        cp -p $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml $TODIR/
        patchYMLfile $TODIR/${HOSTNAME}.yml
    else
        echo "Incorrect YAML file $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml" 1>&2
        exit 10
    fi
else
    echo "Missing $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml" 1>&2
    exit 11
fi

# Generate private and public keys
TODIR=$ROOTDIR/opt/$HOSTNAME
mkdir -p $TODIR
(
    cd $TODIR
    ssh-keygen -t rsa -N '' -b 2048 \
	-C "fw4exCookie@$$HOSTNAME" \
	-f ./fw4excookie
    mv fw4excookie.pub fw4excookie.public.key
    mv fw4excookie     fw4excookie.insecure.key
)

# Pack the files pertaining to the A server:
( 
    echo "Minifying javascript library files..."
    ( cd $PARACAMPLUSDIR/JQuery ; m )
    TGZ=${0%/*}/../RemoteScripts/$MODULE.tgz
    tar czf $TGZ --exclude '*~' \
        -C $PARACAMPLUSDIR/$SRCDIR \
        Templates -C root .
)

# Make sure RemoteScripts has the same configuration:
cp -p ${0%/*}/$HOSTNAME.sh ${0%/*}/../RemoteScripts/$HOSTNAME.sh 

# end of prepare.sh
