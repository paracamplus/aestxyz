#! /bin/bash
# Set a link so the Apache server that runs on the Docker host serves
# static pages directly.

(
    cd /root/Docker/$HOSTNAME/rootfs/var/www/*.paracamplus.com/
    DIR=$(pwd -P)
    for f in *
    do
        ( 
            cd /var/www/$HOSTNAME/
            rm -f $f
            echo ln -sf $DIR/$f ./
            ln -sf $DIR/$f ./
        )
    done
)

if [ $( ls -1 /var/www/$HOSTNAME/static/ | wc -l ) -eq 0 ]
then
    echo "No reachable static files"
    exit 53
fi

# end of check-05-varwwwstatic.sh
