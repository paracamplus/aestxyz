#! /bin/bash

if ! [ -f /root/RemoteScripts/booted ]
then
    /etc/init.d/docker stop
    sleep 1
    date > /root/RemoteScripts/booted
fi

echo "Active processes:"
pstree

echo "This is the end!"

# end of start-99-booted.sh
