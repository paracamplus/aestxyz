#! /bin/bash -x
# This script should be run on the Docker host as root.
# On hostname, install apache configuration to proxy towards the
# container and run the container. Here the container runs an A server
# known as HOSTNAME on Internet.

cd ${0%/*}

HOSTNAME=a.paracamplus.com
HOSTPORT=51080
HOSTSSHPORT=51022
DOCKERNAME=vma
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}

# Prepare ssh keys
if ! [ -r .ssh/authorized_keys ]
then ( 
        ssh-keygen -t rsa -N '' -b 2048 \
            -C "root@$HOSTNAME" \
            -f root_rsa
        mkdir -p .ssh
        cat root_rsa.pub >> .ssh/authorized_keys
     )
fi

docker stop ${DOCKERNAME}
docker rm ${DOCKERNAME}
docker pull ${DOCKERIMAGE}
docker run -d \
    -p "127.0.0.1:${HOSTPORT}:80" \
    -p "127.0.0.1:${HOSTSSHPORT}:22" \
    --name=${DOCKERNAME} -h $HOSTNAME \
    -v /opt/$HOSTNAME/:/opt/$HOSTNAME/private \
    -v `pwd`/.ssh:/root/.ssh \
    ${DOCKERIMAGE} \
    bash -x /root/RemoteScripts/start.sh

rsync -avu ./root.d/etc/apache2/sites-available/$HOSTNAME \
    /etc/apache2/sites-available/
(
    cd /etc/apache2/sites-enabled/
    ln -sf ../sites-available/$HOSTNAME 499-$HOSTNAME
)
if ! /etc/init.d/apache2 restart
then
    tail /var/log/apache2/$HOSTNAME-error.log
fi

# Make sure that this container is run after boot:
( 
    cd ./root.d/
    chmod a+x etc/init.d/qnc-docker.sh
    rsync -avu etc/init.d/qnc-docker.sh /etc/init.d/qnc-docker-$HOSTNAME.sh
    update-rc.d qnc-docker-$HOSTNAME.sh defaults
)

# end of install.sh
