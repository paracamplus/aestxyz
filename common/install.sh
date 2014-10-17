#! /bin/bash -x
# This script should be run on the Docker host as root.
# On hostname, install apache configuration to proxy towards the
# container and run the container.

cd ${0%/*}

source config.sh

if ! [ -r /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key ]
then
    echo "Missing /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key"
    exit 51
fi

if [ -f /opt/common-${HOSTNAME#*.}/dbuser_ecdsa ]
then
    chown -R root: /opt/common-${HOSTNAME#*.}/
    chmod -R 444   /opt/common-${HOSTNAME#*.}/
fi

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

# Container's apache logs are kept on the Docker host
# but they should be rotated by the container.
mkdir -p /var/log/apache2/$HOSTNAME

docker stop ${DOCKERNAME}
docker rm ${DOCKERNAME}
docker pull ${DOCKERIMAGE}
CID=$(docker run -d \
    -p "127.0.0.1:${HOSTPORT}:80" \
    -p "127.0.0.1:${HOSTSSHPORT}:22" \
    --name=${DOCKERNAME} -h $HOSTNAME \
    -v /opt/common-${HOSTNAME#*.}/:/opt/$HOSTNAME/private \
    -v `pwd`/.ssh:/root/.ssh \
    -v /var/log/apache2/$HOSTNAME:/var/log/apache2 \
    ${ADDITIONAL_FLAGS} \
    ${DOCKERIMAGE} \
    bash -x /root/RemoteScripts/start.sh)

if [ -z "$CID" ]
then 
    echo "Starting Docker container $DOCKERNAME failure!"
    exit 52
fi

# Make smoothless the connection between the Docker host and the container:
echo $CID > docker.cid
docker cp ${CID}:/etc/ssh/ssh_host_ecdsa_key.pub .
KEY="$(cat ./ssh_host_ecdsa_key.pub)"
KEY="${KEY%root@*}"
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID})
sed -i -e '/^$IP/d' /root/.ssh/known_hosts
echo "$IP $KEY" >> /root/.ssh/known_hosts

# Allow the container to send mails:
if ${PROVIDE_SMTP:-false}
then
    # Leave time for the container to start sshd:
    # @bijou: 3 seconds
    for t in 1 2 3 4 5 6 7 8 9 10 11 
    do
        sleep 1
        echo "Trying($t) to ssh the container"
        if ssh -p ${HOSTSSHPORT} -i ./root_rsa root@127.0.0.1 hostname
        then
            nohup ssh -nNC -o TCPKeepAlive=yes \
                -i ./root_rsa \
                -R 25:127.0.0.1:25 \
                -p ${HOSTSSHPORT} root@127.0.0.1 &
            break
        fi
    done
fi

# Install specific files on the Docker host and mainly the Apache
# configuration proxying towards the container:
rsync -avu ./root.d/ /
if [ -d ./root.d/etc/apache2/sites-available/ ]
then
    for conf in $( cd ./root.d/etc/apache2/sites-available/ ; ls -1 )
    do (
            cd /etc/apache2/sites-enabled/
            ln -sf ../sites-available/$conf 499-$conf
        )
    done
fi
if ! /etc/init.d/apache2 restart
then
    if [ -f /var/log/apache2/$HOSTNAME-error.log ]
    then
        tail /var/log/apache2/$HOSTNAME-error.log
    else
        tail /var/log/apache2/error.log
    fi
fi

# Make sure that this container is run after reboot of the Docker host:
( 
    cd ./root.d/
    chmod a+x etc/init.d/qnc-docker.sh
    rsync -avu etc/init.d/qnc-docker.sh /etc/init.d/qnc-docker-$HOSTNAME.sh
    rm -f /etc/init.d/qnc-docker.sh
    update-rc.d qnc-docker-$HOSTNAME.sh defaults
)

docker ps -l

# end of install.sh
