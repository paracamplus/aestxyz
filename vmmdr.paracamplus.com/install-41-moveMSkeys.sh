#! /bin/bash
# Runs on the Docker container, install vmms private key in SSHDIR
# so start-41-moveMSkeys.sh will install them at the right place.
# We must also copy the private key of the machine hosting vmms.

( 
    cd ../
    cp -p vmms.paracamplus.com/root_rsa     $SSHDIR/vmms_rsa
    cp -p vmms.paracamplus.com/root_rsa.pub $SSHDIR/vmms_rsa.pub
    cp -p vmms.paracamplus.com/ssh_host_ecdsa_key.pub $SSHDIR/vmms_host.pub
    cp -p vmms.paracamplus.com/docker.ip              $SSHDIR/vmms.ip
)

#NOTA: with the --link option of Docker, the container vmms will be
#known as vmms.paracamplus.com within the vmmdr container. This means
#that copying docker.ip above is no longer necessary.

# end of install-41-moveMSkeys.sh
