#! /bin/bash
# Set a link so the Apache server that runs on the Docker host serves
# static pages directly.

(
    H=${HOSTNAME#test.}
    cd /root/Docker/$HOSTNAME/rootfs/var/www/$H/static/
    DIR=$(pwd -P)
    cd /var/www/$HOSTNAME/
    rm -f static
    echo ln -sf $DIR ./static
    ln -sf $DIR ./static
)

# end of check-05-varwwwstatic.sh
