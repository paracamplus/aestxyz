#! /bin/bash

source /root/RemoteScripts/$HOSTNAME.sh

mkdir -p /opt/$HOSTNAME/exercisedir/1
find /opt/$HOSTNAME/exercisedir -type d | xargs chmod -R 755 
touch /opt/$HOSTNAME/exercisedir/TOUCHED
find /opt/$HOSTNAME/exercisedir -type f | xargs chmod -R 744
rm /opt/$HOSTNAME/exercisedir/TOUCHED
chown -R ${WWWUSER}: /opt/$HOSTNAME/exercisedir

# end of start-56-exerciseDir.sh
