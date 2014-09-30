#! /bin/bash -x
# This script should be run on the Docker host as root.
# On hostname, install apache configuration to proxy towards the
# container and run the container. Here the container runs a Y server
# known as HOSTNAME on Internet.

HOSTNAME=y.paracamplus.com
HOSTPORT=50081
DOCKERNAME=vmy
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}

docker stop ${DOCKERNAME}
docker rm ${DOCKERNAME}
docker pull ${DOCKERIMAGE}
docker run -d -p "127.0.0.1:${HOSTPORT}:80" \
    --name=${DOCKERNAME} -h $HOSTNAME \
    ${DOCKERIMAGE} \
    /root/RemoteScripts/start.sh
# To connect to that container, use: docker attach ${DOCKERNAME}

rsync -avu ${0%/*}/root.d/etc/apache2/sites-available/$HOSTNAME \
    /etc/apache2/sites-available/
(
    cd /etc/apache2/sites-enabled/
    ln -sf ../sites-available/$HOSTNAME 499-$HOSTNAME
)
if ! /etc/init.d/apache2 restart
then
    tail /var/log/apache2/$HOSTNAME-error.log
fi

( 
    cd /root/Docker/${HOSTNAME}/root.d/
    chmod a+x etc/init.d/qnc-docker.sh
    rsync -avu etc/init.d/qnc-docker.sh /etc/init.d/
    update-rc.d qnc-docker.sh defaults
)

# end of install.sh
