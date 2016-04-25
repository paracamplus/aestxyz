#! /bin/bash

echo "Specific directories for E server"
mkdir -p /opt/$HOSTNAME/exercisedir
mkdir -p /opt/$HOSTNAME/incoming
mkdir -p /opt/$HOSTNAME/path
chown -R $APACHEUSER: /opt/$HOSTNAME/

if [ -r /root/RemoteScripts/path.tgz ]
then (
        cd /opt/$HOSTNAME/path
        tar xzf /root/RemoteScripts/path.tgz
    )
else
    echo "Missing /root/RemoteScripts/path.tgz"
    exit 11
fi

# end of setup-11.sh
