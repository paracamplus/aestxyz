#! /bin/bash
# Gather keys for a course frontend.
# We just need the key to access the database.
# NOTA: this script ensures the deployment on HOSTNAME to exist!

mkdir -p $PARACAMPLUSDIR/Docker/${HOSTNAME}
(
    cd $PARACAMPLUSDIR/Servers/.ssh
    tar czf $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.tgz \
        author* student*

    # Identify the keys to be copied (by install.sh) into container's SSHDIR:
    cat > $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.txt <<EOF
FILE dbuser_ecdsa
EOF
)

# end of prepare-50-keys.sh
