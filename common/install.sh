#! /bin/bash -x
# This script should be run on the Docker host as root.
# Install a container in the Docker host and start it.

cd ${0%/*}

INTERACTIVE=false
SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
LOGDIR=/var/log/fw4ex
SETUP=true
DEBUG=false
NEED_FW4EX_MASTER_KEY_DIR=true
SSHDIR=`pwd`/.ssh
SHARE_FW4EX_LOG=true
PROVIDE_APACHE=true
PROVIDE_SMTP=false
source config.sh

# Does the container needs to know the FW4EX master key. This key is
# required for all authenticated requests to the FW4EX machinery.
if ${NEED_FW4EX_MASTER_KEY_DIR}
then
    # Or the master key is in a directory specified by FW4EX_MASTER_KEY_DIR
    # or it is, by default, in /opt/common-paracamplus.com/
    if [ -n "$FW4EX_MASTER_KEY_DIR" ]
    then
        if [ -d $FW4EX_MASTER_KEY_DIR/ ]
        then
            if ! [ -r $FW4EX_MASTER_KEY_DIR/fw4excookie.insecure.key ]
            then
                echo "Unreadable $FW4EX_MASTER_KEY_DIR/fw4excookie.insecure.key"
                exit 51
            fi
        else
            echo "Not a directory $FW4EX_MASTER_KEY_DIR/"
            exit 51
        fi
    elif [ -r /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key ]
    then
        FW4EX_MASTER_KEY_DIR=/opt/common-${HOSTNAME#*.}
    else
        echo "Missing /opt/common-${HOSTNAME#*.}/fw4excookie.insecure.key"
        exit 51
    fi
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v $FW4EX_MASTER_KEY_DIR:/opt/$HOSTNAME/private "
fi

usage () {
    cat <<EOF
Usage: ${0##*/} [option]
  -i        interactive mode, start a bash interpreter
  -s N      stop the container after N seconds
  -n        do not run any setup-*.sh sub-scripts
  -e CMD    run CMD instead of start.sh (and its options) in the container
Default option is -s $SLEEP

This script should be run on a Docker host. It installs and starts a
new container. Most of these options (s, i, n)are mainly passed to the
starting script of the container. Option -e imposes the starting script.
EOF
}

while getopts e:s:in opt
do
    case "$opt" in
        e)
            # Run this command in the container then exit. 
            INTERACTIVE=true
            COMMAND="$OPTARG"
            ;;
        i)
            # Start an interactive session (useful for debug):
            INTERACTIVE=true
            #COMMAND is implicitly bash
            ;;
        s)
            # Exit from the container after that number of seconds.
            INTERACTIVE=false
            SLEEP=$OPTARG
            ;;
        n)
            # Don't run setup-*.sh sub-scripts
            INTERACTIVE=false
            SETUP=false
            ;;
        \?)
            echo "Bad option $opt"
            usage
            exit 41
            ;;
    esac
done

START_FLAGS=
if ! $INTERACTIVE
then
    if $SETUP
    then
        START_FLAGS="-s $SLEEP"
    else
        START_FLAGS="-n -s $SLEEP"
    fi
fi

# Prepare ssh keys
if ! [ -r ${SSHDIR}/authorized_keys ]
then
    if ! [ -f root_rsa ]
    then
        ssh-keygen -t rsa -N '' -b 2048 \
            -C "root@$HOSTNAME" \
            -f root_rsa
    fi
    mkdir -p ${SSHDIR}
    cp root* ${SSHDIR}/
    cat root_rsa.pub > ${SSHDIR}/authorized_keys
fi
# These are the names expected by Paracamplus/FW4EX/VM.pm          HACK
cp root_rsa.pub root.pub
cp root_rsa     root
chmod a=r $SSHDIR/root*

# Expand the keys for authors and students:
if [ -f keys.tgz ]
then
    cp keys.tgz ${SSHDIR}/
    ( 
        cd $SSHDIR
        tar xzf keys.tgz
    )
else
    echo "Missing `pwd`/keys.tgz"
    exit 42
fi

if ${SHARE_FW4EX_LOG}
then
    # Container's fw4ex logs are kept on the Docker host
    # but they should be rotated by the container.
    mkdir -p $LOGDIR
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v ${LOGDIR}:/var/log/fw4ex"
fi

if ${PROVIDE_APACHE}
then
    # Container's apache logs are kept on the Docker host
    # but they should be rotated by the container.
    mkdir -p /var/log/apache2/$HOSTNAME
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -p 127.0.0.1:${HOSTPORT}:80 "
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v /var/log/apache2/$HOSTNAME:/var/log/apache2 "
fi

if ! docker version 
then
    echo "Docker is not available"
    exit 48
fi
docker pull ${DOCKERIMAGE}
docker stop ${DOCKERNAME} 
docker rm   ${DOCKERNAME}

if $DEBUG
then
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS  -v /dev/log:/dev/log "
fi

if $INTERACTIVE
then
    # NOTA: sometimes useful:   -v /dev/log:/dev/log \
    if [ -n "$COMMAND" ]
    then 
        docker run --rm \
            ${ADDITIONAL_FLAGS} \
            -p "127.0.0.1:${HOSTSSHPORT}:22" \
            --name=${DOCKERNAME} -h $HOSTNAME \
            -v ${SSHDIR}:/root/.ssh \
            ${DOCKERIMAGE} \
            "$COMMAND"
    else
        docker run -it \
            ${ADDITIONAL_FLAGS} \
            -p "127.0.0.1:${HOSTSSHPORT}:22" \
            --name=${DOCKERNAME} -h $HOSTNAME \
            -v ${SSHDIR}:/root/.ssh \
            ${DOCKERIMAGE} 
    fi
    exit $?
else
    CID=$(docker run -d \
        ${ADDITIONAL_FLAGS} \
        -p "127.0.0.1:${HOSTSSHPORT}:22" \
        --name=${DOCKERNAME} -h $HOSTNAME \
        -v ${SSHDIR}:/root/.ssh \
        ${DOCKERIMAGE} \
        bash -x /root/RemoteScripts/start.sh $START_FLAGS )
fi

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
echo $IP > docker.ip
touch $HOME/.ssh/known_hosts
sed -i -e '/^$IP/d' $HOME/.ssh/known_hosts
echo "$IP $KEY"  >> $HOME/.ssh/known_hosts
if [ -d /var/lib/docker/devicemapper/mnt/$CID/rootfs/ ]
then
    echo "$DOCKERNAME file system: /var/lib/docker/devicemapper/mnt/$CID/rootfs/"
elif [ -d /var/lib/docker/aufs/mnt/$CID/ ]
then
    echo "$DOCKERNAME file system: /var/lib/docker/aufs/mnt/$CID/"
fi

# Allow the container to send mails:
if ${PROVIDE_SMTP}
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
    # Install specific files on the Docker host 
    rsync -avu ./root.d/ /

    # and mainly the Apache configuration proxying towards the container:
    if ${PROVIDE_APACHE}
    then
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
    fi

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

#check "end of start.sh" ???

# end of install.sh
