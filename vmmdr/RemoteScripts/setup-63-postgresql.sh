#! /bin/bash

(
    PGVERSION=9.1
    cd /var/lib/postgresql/$PGVERSION/main/
    rm -f server.key 2>/dev/null
    cat < /etc/ssl/private/ssl-cert-snakeoil.key > server.key
    chown postgres: server.key
    chmod 740 server.key
    #ls -l #DEBUG
    cd /etc/postgresql/$PGVERSION/main/
    chown -R postgres: .
    #ls -l #DEBUG

    # Set timezone in Postgres
    f=/etc/postgresql/$PGVERSION/main/postgresql.conf
    if grep -q "timezone = 'UTC'" < $f
    then
        echo "timezone = 'UTC' " >> $f
    fi
)

# This is to avoid an 'absent parent directory':
cd

if ! /etc/init.d/postgresql start
then
    echo "Cannot start Postgresql"
    tail -20 /var/log/postgresql/postgresql-*.log
    exit 46
fi

#echo "createuser -s root" | su - postgres
su -c "createuser -s root" postgres

if psql -l | grep fw4ex
then 
    if dropdb fw4ex
    then : 
    else
        echo "Cannot drop database!"
        exit 2;
    fi
fi
if createdb -E UTF-8 -l en_US.UTF-8 -O postgres -T template0 fw4ex
then :
else
    echo "Cannot create database!"
    exit 3
fi
if psql -l </dev/null | grep -q fw4ex 
then :
else
    echo "Could not create fw4ex database!"
    exit 1
fi

createuser -s queinnec 

# NOTA: passwords inside fw4ex.sql!
trap "rm -f /opt/$HOSTNAME/*fw4ex.sql" 0
sed -e '/to saver/d' \
    -e '/to camplou/d' < /opt/$HOSTNAME/fw4ex.sql | psql fw4ex
psql fw4ex -f /opt/$HOSTNAME/post-fw4ex.sql

if ! /etc/init.d/postgresql stop
then
    echo "Cannot stop Postgresql"
    tail -20 /var/log/postgresql/postgresql-*.log
    exit 46
fi

# end of setup-63-postgresql.sh
