#! /bin/bash -e

echo "Specific directories for A server"
mkdir -p /opt/$HOSTNAME/tmpdir
mkdir -p /opt/$HOSTNAME/batchdir
mkdir -p /opt/$HOSTNAME/jobdir
chown -R ${APACHEUSER}: /opt/$HOSTNAME/*dir

echo "Restaure ownership and rights"
chown -R $APACHEUSER: /var/www/$HOSTNAME
chown -R $APACHEUSER: /opt/$HOSTNAME
chmod 444 /opt/$HOSTNAME/?*.?*
chmod 440 /opt/$HOSTNAME/fw4excookie.insecure.key

# end of setup-10.sh
