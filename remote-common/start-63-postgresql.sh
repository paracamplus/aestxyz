#! /bin/bash

if [ -f /root/RemoteScripts/booted ]
then
    if ! /etc/init.d/postgresql start
    then
        echo "Cannot start Postgresql"
        exit 46
    fi
fi

# end of start-63-postgresql.sh
