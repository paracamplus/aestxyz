#! /bin/bash
# Set a link so the Apache server that runs on the Docker host serves
# static pages directly.

if [ -d /root/Docker/$HOSTNAME/rootfs ]
then
    if [ -d /root/Docker/$HOSTNAME/rootfs/var/www/$INNERHOSTNAME/ ]
    then (
            cd /root/Docker/$HOSTNAME/rootfs/var/www/$INNERHOSTNAME/
            DIR=$(pwd -P)
            mkdir -p /var/www/$HOSTNAME
            for f in *
            do
                case "$f" in 
                    dbuser_ecdsa*|keys.t*|ssh*|*docker*|install.sh)
                        break
                        ;;
                    nohup.out|check-*|config.sh|root|root.d|root.pub|*~) 
                        break
                        ;;
                esac
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
    else 
        echo "No inner /var/www/$INNERHOSTNAME/"
        exit 53
    fi

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

else
    echo "WARNING: Docker rootfs not set"
    # Maybe use 'docker cp ' instead ?????
fi

# end of check-05-varwwwstatic.sh
