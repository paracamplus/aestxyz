#! /bin/bash

export LANG=C
source /root/RemoteScripts/$HOSTNAME.sh

# This directory must be writable by server E to welcome new exercises:
chown -R ${WWWUSER}: /opt/$HOSTNAME/incoming/

# end of start-56-incoming.sh
