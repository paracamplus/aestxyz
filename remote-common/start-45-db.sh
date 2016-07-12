#! /bin/bash
# Set up the connection of the Docker container towards the database that
# resides on the Docker host. Make sure that the perl webapp sees it.
# If the socket towards the Postgresql server is available, we use it,
# otherwise we resort to an ssh connection.

mkdir -p /opt/tmp/$HOSTNAME
# cat >/opt/tmp/$HOSTNAME/pg_service.conf <<EOF
# [viasocket]
# dbname=fw4ex
# host=/var/run/postgresql

# [viatcp]
# dbname=fw4ex
# host=127.0.0.1
# EOF

checkSocket () {
    echo "psql fw4ex --user web2user -c \"select 'fw4extime', current_time as fw4extime;\" " | \
        su - www-data | grep fw4extime
}

socket=/var/run/postgresql/.s.PGSQL.5432
export PGWAY=viatcp
if [ -r $socket ]
then
    if checkSocket
    then
        #export PGSERVICEFILE=/opt/tmp/$HOSTNAME/pg_service.conf
        export PGWAY=viasocket
    else
        echo "Cannot connect to database via $socket"
        #export PGSERVICEFILE=/opt/tmp/$HOSTNAME/pg_service.conf
        export PGWAY=viatcp
        # The ssh tunnel will be opened later by start-65-dbtunnel.sh
    fi
fi

if [ "$PGWAY" = viatcp ]
then
    if ! [ -f /root/RemoteScripts/start-65-dbtunnel.sh ]
    then
        echo "Missing script /root/RemoteScripts/start-65-dbtunnel.sh"
        exit 55
    fi
fi

(
    cd /opt/$HOSTNAME
    #NOTA: don't use 'sed -i' since it performs a kind of 'mv' incompatible
    # with the way Docker mounts this file in zvmauthor
    cp -p $HOSTNAME.yml $HOSTNAME.ymlbak
    sed -e "/^${PGWAY}-Model::FW4EXDB/s#${PGWAY}-##" \
        < $HOSTNAME.ymlbak > $HOSTNAME.yml
)

# end of start-45-db.sh
