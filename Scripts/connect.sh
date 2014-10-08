#! /bin/bash
# Connect to one of the running Docker container.

DOMAIN=paracamplus.com

cd ${0%/*}/

usage () {
    cat <<EOF
Usage: ${0##*/} host
Connect via ssh to the Docker container named by the argument.
Hosts within domain $DOMAIN may be nicknamed.
Possible hosts are: $(cd Docker; ls)
EOF
}

if [ $# -eq 0 ]
then
    usage
    exit 
fi

WHERE=${1}

if [ -d ../$WHERE.paracamplus.com ]
then 
    source ../$WHERE.paracamplus.com/config.sh
    ssh -p $HOSTSSHPORT -i ../$WHERE.paracamplus.com/root_rsa root@127.0.0.1
elif [ -d $WHERE ]
then
    source ../$WHERE/config.sh
    ssh -p $HOSTSSHPORT -i ../$WHERE/root_rsa root@127.0.0.1
else
    echo "No such host"
    usage
    exit 1
fi

# end of connect.sh
