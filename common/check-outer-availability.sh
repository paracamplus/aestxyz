#! /bin/bash
# Check availability of some servers out of its Docker container
# This script runs in the Docker host.
# Usage:  check-outer-availability.sh a.paracamplus.net e.paracamplus.net ...
#    The arguments are the hostname to request.
# This script is parameterized via two variables:
#    URL       the URL to get (by default http://127.0.0.1/
#    FRAGMENT  the fragment of text that must be present in the response.

PORT=80
IP=127.0.0.1

while getopts p:s:i: opt
do
    case "$opt" in
        p|port)
            PORT=$OPTARG
            ;;
        s|sleep)
            sleep $OPTARG
            ;;
        i|ip)
            IP=$OPTARG
            ;;
        \?)
            echo "Bad option $opt"
            exit 31
            ;;
    esac
done
shift $(( $OPTIND - 1 ))

rm -f /tmp/wget_code.txt
for HOSTNAME
do (
        echo "Outer check of $HOSTNAME"
        VERSION=$(cat */$HOSTNAME/root.d/opt/$HOSTNAME/VERSION.txt)
        wget -O - -o /dev/null \
            --header="HOST:$HOSTNAME" \
            http://$IP:$PORT/ > /tmp/wget_$HOSTNAME.txt
        if grep -i "version: $VERSION" < /tmp/wget_$HOSTNAME.txt
        then 
            :
        else
            echo '***************** Problem (missing or wrong version)!'
            cat /tmp/wget_$HOSTNAME.txt
            echo 32 > /tmp/wget_code.txt
            exit 32
        fi
    )
    if [ -f /tmp/wget_code.txt ]
    then exit $(< /tmp/wget_code.txt)
    fi
done

# end of check-outer-availability.sh
