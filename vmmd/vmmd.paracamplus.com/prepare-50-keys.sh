#! /bin/bash
# Gather keys for a marking driver:

(
    cd $PARACAMPLUSDIR/Servers/.ssh
    tar czf $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.tgz \
        author* student*
    # DSA keys to log as fw4ex on s.paracamplus.com:
    cp -p fw4ex fw4ex.pub $PARACAMPLUSDIR/Docker/${HOSTNAME}/
    # DSA keys to log as saver on db.paracamplus.com:
    cp -p saver_dsa saver_dsa.pub $PARACAMPLUSDIR/Docker/${HOSTNAME}/

    # Identify the keys to be copied (by install.sh) into container's SSHDIR:
    cat > $PARACAMPLUSDIR/Docker/${HOSTNAME}/keys.txt <<EOF
UNTAR keys.tgz
FILE fw4ex
FILE fw4ex.pub
FILE saver_dsa
FILE saver_dsa.pub
EOF
)

# end of prepare-50-keys.sh
