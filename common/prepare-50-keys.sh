#! /bin/bash
# Gather keys for a course frontend:

(
    cd $PARACAMPLUSDIR/Servers/.ssh
    tar czf $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.tgz \
        author* student*

    # Identify the keys to be copied (by install.sh) into container's SSHDIR:
    cat > $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.txt <<EOF
keys.tgz
EOF
)

# end of prepare-50-keys.sh
