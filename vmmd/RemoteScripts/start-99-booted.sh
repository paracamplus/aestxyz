#! /bin/bash

if ! [ -f /root/RemoteScripts/booted ]
then
    /etc/init.d/docker stop
    date > /root/RemoteScripts/booted
fi

# end of start-99-booted.sh
