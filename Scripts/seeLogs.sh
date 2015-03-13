#! /bin/bash
# This script should be installed in /root/Docker/Scripts/,
# It runs in the /root/Docker/ directory.

DOMAIN=paracamplus.com

cd ${0%/*}/../

usage () {
    cat <<EOF
Usage: ${0##*/} host
Show the logs of Apache running in the Docker host and the logs
of the web server running in the Docker container.
Hosts within domain $DOMAIN may be nicknamed.
Possible hosts are: $(ls)
EOF
}

if [ ! -f $HOME/.multitailrc ]
then
    echo 'check_mail:0' > $HOME/.multitailrc
fi

WHERE=$1

if [ -d $WHERE.paracamplus.com ]
then
    WHERE="$WHERE.paracamplus.com"
fi

if [ -d $WHERE ]
then
    multitail --mark-interval 100 --follow-all \
        -i /var/log/apache2/$WHERE-access.log \
        -i /var/log/apache2/$WHERE-error.log \
        -i /var/log/apache2/$WHERE/access.log \
        -i /var/log/apache2/$WHERE/error.log 
else
    echo "No such host ($WHERE)"
    usage
    exit 1
fi

# end of seeLogs.sh
