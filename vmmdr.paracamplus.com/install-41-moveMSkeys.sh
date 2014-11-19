#! /bin/bash
# Runs on the Docker container, install vmms private key in SSHDIR
# so start-41-moveMSkeys.sh may install them at the right place.

( 
    cd ../
    cp -p vmms.paracamplus.com/root_rsa     $SSHDIR/vmms_rsa
    cp -p vmms.paracamplus.com/root_rsa.pub $SSHDIR/vmms_rsa.pub
)

# end of install-41-moveMSkeys.sh
