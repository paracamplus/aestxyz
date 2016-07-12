#! /bin/bash

if [ -f /root/RemoteScripts/booted ]
then
    socket=/var/run/postgresql/.s.PGSQL.5432
    if [ -r $socket ]
    then 
        echo "Using existing socket for Postgresql"
        # NOTA setup-63-postgresql.sh initializes the database, using
        # that socket assumes that an equivalent initialisation had
        # been performed.
    else
        echo "Starting Postgresql daemon"
        if ! /etc/init.d/postgresql start
        then
            echo "Cannot start Postgresql"
            exit 42
        fi
    fi
fi

# end of start-63-postgresql.sh
