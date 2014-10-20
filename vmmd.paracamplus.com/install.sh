#! /bin/bash -x
# This script should be run on the Docker host as root.
# Inspired by vmms.*/install.sh but adapted for a Marking Driver.

cd ${0%/*}

INTERACTIVE=false
SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
LOGDIR=/var/log/fw4ex/md
source config.sh

while getopts s:ie: opt
do
    case "$opt" in
        i)
            # Start an interactive session (useful for debug):
            INTERACTIVE=true
            ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS"
            ;;
        e)
            # Run this command in the container then exit. 
            # Only with -i
            COMMAND="$OPTARG"
            ;;
        s)
            # Exit from the container after that number of seconds.
            # Useless with -i
            SLEEP=$OPTARG
            ;;
        \?)
            echo "Bad option $opt"
            exit 41
            ;;
    esac
done

if $INTERACTIVE
then
    COMMAND="${COMMAND:- bash -x /root/RemoteScripts/start.sh -i }"
fi

if ! [ -r /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key ]
then
    echo "Missing /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key"
    exit 51
fi

# Prepare ssh keys
SSHDIR=${SSHDIR:-`pwd`/.ssh}
if ! [ -r ${SSHDIR}/authorized_keys ]
then
    if ! [ -f root_rsa ]
    then
        ssh-keygen -t rsa -N '' -b 2048 \
            -C "root@$HOSTNAME" \
            -f root_rsa
    fi
    mkdir -p ${SSHDIR}
    cat root_rsa.pub > ${SSHDIR}/authorized_keys
fi
# # These are the names expected by Paracamplus/FW4EX/VM.pm
# ln -sf root_rsa.pub root.pub
# ln -sf root_rsa     root

# Expand the keys for authors and students:
cp keys.tgz ${SSHDIR}/
( 
    cd $SSHDIR
    tar xzf keys.tgz
)

# # Copy ssh keys for authors and students:
# rsync -avu ../../Servers/.ssh/{author,student}* ${SSHDIR}/ 2>/dev/null

# Container's fw4ex logs are kept on the Docker host
# but they should be rotated by the container.
mkdir -p $LOGDIR

docker pull ${DOCKERIMAGE}
docker stop ${DOCKERNAME} && docker rm ${DOCKERNAME}

if $INTERACTIVE
then
    # NOTA: sometimes useful:   -v /dev/log:/dev/log \
    docker run \
        ${ADDITIONAL_FLAGS} \
        -p "127.0.0.1:${HOSTSSHPORT}:22" \
        --name=${DOCKERNAME} -h $HOSTNAME \
        -v ${SSHDIR}:/root/.ssh \
        -v ${LOGDIR}:/var/log/fw4ex \
        ${DOCKERIMAGE} \
        "$COMMAND"
    exit $?
else
    CID=$(docker run \
        ${ADDITIONAL_FLAGS:- '-d' } \
        -p "127.0.0.1:${HOSTSSHPORT}:22" \
        --name=${DOCKERNAME} -h $HOSTNAME \
        -v ${SSHDIR}:/root/.ssh \
        -v ${LOGDIR}:/var/log/fw4ex \
        ${DOCKERIMAGE} \
        bash -x /root/RemoteScripts/start.sh -s $SLEEP )
fi

# Make smoothless the connection between the Docker host and the container:
echo $CID > docker.cid
docker cp ${CID}:/etc/ssh/ssh_host_ecdsa_key.pub .
KEY="$(cat ./ssh_host_ecdsa_key.pub)"
KEY="${KEY%root@*}"
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID})
sed -i -e '/^$IP/d' $HOME/.ssh/known_hosts
echo "$IP $KEY"  >> $HOME/.ssh/known_hosts

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

# Install specific files on the Docker host:
if [ -d root.d ]
then
    rsync -avu ./root.d/ /
    # Make sure that this container is run after reboot of the Docker host:
    ( 
        cd ./root.d/
        chmod a+x etc/init.d/qnc-docker.sh
        rsync -avu etc/init.d/qnc-docker.sh /etc/init.d/qnc-docker-$HOSTNAME.sh
        rm -f /etc/init.d/qnc-docker.sh
        update-rc.d qnc-docker-$HOSTNAME.sh defaults
    )
fi

# Leave time for the container to be up and accept ssh connections:
sleep 1
docker ps -l

# end of install.sh
