#! /bin/bash
# Set a link so the Apache server that runs on the Docker host serves
# static pages directly.

(
    cd /root/Docker/$HOSTNAME/rootfs/var/www/*.paracamplus.com/
    DIR=$(pwd -P)
    mkdir -p /var/www/$HOSTNAME
    for f in *
    do
        ( 
            cd /var/www/$HOSTNAME/
            if [ -d $f ]
            then
                rm -rf $f
            else
                rm -f $f
            fi
            echo ln -sf $DIR/$f ./
            ln -sf $DIR/$f ./
        )
    done
)

if [ -f /var/www/$HOSTNAME/favicon.ico ]
then
    if [ $( wc -c < /var/www/$HOSTNAME/favicon.ico ) -eq 0 ]
    then
        echo "No reachable static files"
        exit 53
    fi
else
    echo "Missing file /var/www/$HOSTNAME/favicon.ico"
    exit 53
fi

# end of check-05-varwwwstatic.sh
