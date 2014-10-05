#! /bin/bash -e
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
mkdir -p $ROOTDIR

# if forgotten:
mkdir -p ${0%/*}/../RemoteScripts

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

# Generating Catalyst Controllers
if [ -n "$SRCDIR" ]
then
    SanitizedHOSTNAME=${HOSTNAME//./_}
    SanitizedHOSTNAME=${SanitizedHOSTNAME//-/_}
    TODIR=$ROOTDIR/usr/local/lib/site_perl/Paracamplus/FW4EX/${MODULE}
    mkdir -p $TODIR
    echo "Generating Catalyst controller $SanitizedHOSTNAME.pm"
    $PARACAMPLUSDIR/Scripts/compilePath.pl --perl \
        --servername $HOSTNAME \
        --perlmodule Paracamplus-FW4EX-$MODULE \
        --version "$VERSION" \
        -o $TODIR/${SanitizedHOSTNAME}.pm
    echo "Generating Catalyst controller $MODULE.pm"
    $PARACAMPLUSDIR/Scripts/compilePath.pl --perl \
        --perlmodule Paracamplus-FW4EX-$MODULE \
        --version "$VERSION" \
        -o $TODIR.pm
fi

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
elif [ -r $TODIR/${HOSTNAME}.yml ]
then
    if $PARACAMPLUSDIR/Scripts/checkYAML.pl \
        $TODIR/${HOSTNAME}.yml
    then
        patchYMLfile $TODIR/${HOSTNAME}.yml
    else
        echo "Incorrect YAML file $TODIR/${HOSTNAME}.yml" 1>&2
        exit 12
    fi
elif [ -n "$SRCDIR" ]
then
    echo "Missing $PARACAMPLUSDIR/$SRCDIR/${HOSTNAME}.yml" 1>&2
    exit 11
else
    # This server does not use Catalyst
    :
fi

if [ 1 -le $( ls -1 ${0%/*}/prepare-??*.sh 2>/dev/null | wc -l ) ]
then 
    for f in ${0%/*}/prepare-??*.sh
    do
        echo "Sourcing $f"
        source $f
        status=$?
        if [ $status -gt 0 ]
        then exit $status
        fi
    done
fi

# Docker takes a very long time to process an instruction such as
#     ADD root.d/  /
# this way is much faster but requires cooperation from setup.sh:
echo "Tar-ing root.d"
tar czhf ${0%/*}/../RemoteScripts/root-$MODULE.tgz \
    --exclude='*~' --exclude='*.bak' -C $ROOTDIR .

# Make sure RemoteScripts has the same configuration:
cp -p ${0%/*}/$HOSTNAME.sh ${0%/*}/../RemoteScripts/$HOSTNAME.sh 

# end of prepare.sh
