#! /bin/bash -x
# Check availability of a server out of its Docker container
# This script runs in the Docker host.

export HOSTNAME="$(cd ${0%/*} ; pwd)"
HOSTNAME=${HOSTNAME##*/}
source ${0%/*}/$HOSTNAME.sh

PORT=50080
IP=127.0.0.1

while getopts p:s:i: opt
do
    case "$opt" in
        p)
            PORT=$OPTARG
            ;;
        s)
            sleep $OPTARG
            ;;
        i)
            IP=$OPTARG
            ;;
        *)
            echo "Bad option $opt"
            ;;
    esac
done

VERSION=$(cat ${0%/*}/root.d/opt/$HOSTNAME/VERSION.txt)

wget -O - -o /dev/null \
    --header="HOST:$HOSTNAME" \
    http://$IP:$PORT/ > /tmp/wget_$HOSTNAME.txt
if grep -i "version: $VERSION" < /tmp/wget_$HOSTNAME.txt
then 
    rm -f /tmp/wget_$HOSTNAME.txt
else
    echo '***************** Probleme'
    cat /tmp/wget_$HOSTNAME.txt
    exit 1
fi

# end of check-availability.sh
