#! /bin/bash
# Gather keys for a marking driver:

(
    cd $PARACAMPLUSDIR/Servers/.ssh
    tar czf $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.tgz \
        author* student*
    # RSA keys to log as fw4ex on s.paracamplus.com:
    cp -p fw4ex fw4ex.pub $PARACAMPLUSDIR/Docker/${HOSTNAME}/
    # RSA keys to log as saver on db.paracamplus.com:
    cp -p saver2_rsa saver2_rsa.pub $PARACAMPLUSDIR/Docker/${HOSTNAME}/

    # Identify the keys to be copied (by install.sh) into container's SSHDIR:
    cat > $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.txt <<EOF
UNTAR keys.tgz
FILE fw4ex
FILE fw4ex.pub
FILE saver2_rsa
FILE saver2_rsa.pub
EOF
)

# end of prepare-51-keys.sh
