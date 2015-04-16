#! /bin/bash
# Prepare how to install vmms inside vmmd
# We are supposed to be in Docker/vmmd/vmmd.paracamplus.com/

(
    VMMS=vmms.paracamplus.com
    # Return to the /Docker/ directory:
    cd ${0%/*}/../../
    mkdir -p $ROOTDIR/opt/$HOSTNAME/Docker/$VMMS
    rsync -avuL $VMMS/{install,config}.sh $ROOTDIR/opt/$HOSTNAME/Docker/$VMMS/
    #NOTA: in the vmmd container, /opt/$HOSTNAME/Docker/$VMMS/
    #      will be moved to /root/Docker/$VMMS/
)

# end of prepare-65-docker.sh
