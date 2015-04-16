#! /bin/bash
# Gather keys for a marking slave:

(
    cd $PARACAMPLUSDIR/Servers/.ssh
    tar czf $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.tgz \
        author* student*

    # Identify the keys to be copied (by install.sh) into container's SSHDIR:
    cat > $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.txt <<EOF
UNTAR keys.tgz
EOF
)

# end of prepare-52-keys.sh
