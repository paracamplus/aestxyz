#! /bin/bash
# Connect to one of the running Docker container. This script
# should be run in /root/Docker/ directory

DOMAIN=paracamplus.com

cd ${0%/*}/../

usage () {
    cat <<EOF
Usage: ${0##*/} host
Connect via ssh to the Docker container named by the argument.
Hosts within domain $DOMAIN may be nicknamed.
Possible hosts are: $(ls)
EOF
}

if [ $# -eq 0 ]
then
    usage
    exit 
fi

WHERE=${1}

if [ -d $WHERE.$DOMAIN ]
then
    WHERE="$WHERE.$DOMAIN"
fi

if [ -d $WHERE ]
then
    source $WHERE/config.sh
    if ! [ -r $WHERE/root_rsa ]
    then
        echo "Cannot read $WHERE/root_rsa"
        ls -l $WHERE/root_rsa
        exit 1
    fi
    ssh -p ${HOSTSSHPORT:-22} -i $WHERE/root_rsa root@127.0.0.1
else
    echo "No such host ($WHERE)"
    usage
    exit 1
fi

# end of connect.sh
