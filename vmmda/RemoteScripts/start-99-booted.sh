#! /bin/bash

if ! [ -f /root/RemoteScripts/booted ]
then
    # See https://github.com/jpetazzo/dind/issues/19
    start-stop-daemon --stop --pidfile "/var/run/docker.pid"

    # Record the end of the bootstrap:
    echo "Creation of /root/RemoteScripts/booted"
    date > /root/RemoteScripts/booted
fi

# Some cleanup
rm -f /var/log/fw4ex/md/* 2>/dev/null
rm -f /var/log/fw4ex/ms/* 2>/dev/null

echo "Still active processes:"
pstree

echo "This is the end!"

# end of start-99-booted.sh
