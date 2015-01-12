#! /bin/bash
# Remove files generated when starting a Docker container. This script
# should be run in /root/Docker/ directory

DOMAIN=paracamplus.com

cd ${0%/*}/../

usage () {
    cat <<EOF
Usage: ${0##*/} host ...
Stop the container and remove associated generated files.
Hosts within domain $DOMAIN may be nicknamed.
Possible hosts are: $(ls)
EOF
}

stopclean () {
    local WHERE=$1
    echo stopclean $WHERE ... 1>&2

    if [ -d $WHERE.$DOMAIN ]
    then
        WHERE="$WHERE.$DOMAIN"
    fi
    
    if [ -d $WHERE ]
    then
        source $WHERE/config.sh
        docker stop ${DOCKERNAME}
        ( 
            cd $WHERE
            rm -rf ssh.d
            rm root root.pub root_rsa root_rsa.pub
            rm -f rootfs docker.ip docker.tag docker.cid nohup.out
        )
    else
        echo "No such host ($WHERE)"
        usage
        exit 1
    fi
}

if [ $# -eq 0 ]
then 
    # Stop clean all possible containers
    for WHERE in *.$DOMAIN
    do
        stopclean $WHERE
    done
else
    # Stop the specified containers:
    for WHERE
    do 
        stopclean $WHERE
    done
fi

# end of stopclean.sh
