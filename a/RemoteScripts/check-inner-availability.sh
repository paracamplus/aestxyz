#! /bin/bash -x
# Check availability of a server from within its Docker container

HOSTNAME=${HOSTNAME:-no.host.name}
source ${0%/*}/$HOSTNAME.sh

if /etc/init.d/apache2 start 
then 
    sleep 2
else
    tail -n20 /var/log/apache2/error.log
    exit 31
fi

VERSION=$(cat /opt/$HOSTNAME/VERSION.txt)

wget -O - -o /dev/null  \
    --header="HOST:$HOSTNAME" \
    ${URL:-http://127.0.0.1/} > /tmp/wget_$HOSTNAME.txt
if grep -i "version: $VERSION" < /tmp/wget_$HOSTNAME.txt
then 
    rm -f /tmp/wget_$HOSTNAME.txt
else
    echo '***************** Problem!'
    cat /tmp/wget_$HOSTNAME.txt
    exit 32
fi

# end of check-availability.sh
