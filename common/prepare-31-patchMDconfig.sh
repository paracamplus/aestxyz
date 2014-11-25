#! /bin/bash
# Patch md-config.yml

TODIR=$ROOTDIR/opt/$HOSTNAME/
mkdir -p $TODIR

patchYMLfile $TODIR/md-config.yml

# end of prepare-31-patchMDconfig.sh
