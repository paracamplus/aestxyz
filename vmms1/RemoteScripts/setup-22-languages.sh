#! /bin/bash
# Runs as root within the container
# May also be run directly from the Dockerfile before setup.sh

HOSTNAME=${HOSTNAME:-no.host.name}
source ${0%/*}/$HOSTNAME.sh

if [ -f /root/RemoteScripts/root-$MODULE.tgz ]
then ( 
        echo "Populate container"
        cd /
        tar xvzf /root/RemoteScripts/root-$MODULE.tgz || exit 21
        rm -f /root/RemoteScripts/root-$MODULE.tgz
     )
fi

/root/RemoteScripts/install-java.sh
/root/RemoteScripts/install-racket.sh
/root/RemoteScripts/install-bigloo.sh

# end of setup-22-languages.sh
