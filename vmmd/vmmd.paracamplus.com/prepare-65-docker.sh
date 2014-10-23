#! /bin/bash
# Prepare how to install vmms inside vmmd

(
    VMMS=vmms.paracamplus.com
    # Return to the /Docker/ directory:
    cd ${0%/*}/../../
    mkdir -p $ROOTDIR/opt/$HOSTNAME/Docker/$VMMS
    rsync -avu $VMMS/{install,config}.sh $ROOTDIR/opt/$HOSTNAME/Docker/$VMMS/
)

# end of prepare-65-docker.sh
