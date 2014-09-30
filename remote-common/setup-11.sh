#! /bin/bash

echo "Specific directories for E server"
mkdir -p /opt/$HOSTNAME/exercisedir
mkdir -p /opt/$HOSTNAME/incoming
mkdir -p /opt/$HOSTNAME/path
chown -R $APACHEUSER: /opt/$HOSTNAME/

# Since we assume that the A server is installed, 
cp -p /opt/a.${HOSTNAME#e.}/fw4excookie.insecure.key /opt/$HOSTNAME/

# end of setup-11.sh
