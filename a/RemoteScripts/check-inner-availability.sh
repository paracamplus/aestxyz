#! /bin/bash
# Check availability of some servers from within its Docker container
# Usage:  check-inner-availability.sh a.paracamplus.net e.paracamplus.net ...
#    The arguments are the hostname to request.
# This script is parameterized via two variables:
#    URL       the URL to get (by default http://127.0.0.1/
#    FRAGMENT  the fragment of text that must be present in the response.

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

for HOSTNAME
do (
        echo "Inner check of $HOSTNAME"
        source ${0%/*}/$HOSTNAME.sh
        wget -O - -o /dev/null  \
            --header="HOST:$HOSTNAME" \
            ${URL:-http://127.0.0.1/} > /tmp/wget_$HOSTNAME.txt
        if grep -i "version: $VERSION" < /tmp/wget_$HOSTNAME.txt
        then 
            if grep -q "${FRAGMENT:-}" < /tmp/wget_$HOSTNAME.txt
            then
                rm -f /tmp/wget_$HOSTNAME.txt
            else
                echo '***************** Problem (missing fragment)!'
                cat /tmp/wget_$HOSTNAME.txt
                exit 33
            fi
        else
            echo '***************** Problem (wrong version)!'
            cat /tmp/wget_$HOSTNAME.txt
            exit 32
        fi
    )
done

# end of check-inner-availability.sh