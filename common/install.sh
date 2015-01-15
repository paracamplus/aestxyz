#! /bin/bash -x
# This script should be run on the Docker host as root.
# Install a container in the Docker host and start it.

# Usually, this script is run in /root/Docker/HOSTNAME/ where
# - it will find the specific configuration: config.sh
# - and write some files describing the container: docker.{cid,ip}
# - meanwhile, keys are generated to connect to the container via ssh.
cd ${0%/*}/

INTERACTIVE=false
SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
LOGDIR=/var/log/fw4ex
SETUP=true
DEBUG=false
NEED_FW4EX_MASTER_KEY_DIR=true
SSHDIR=`pwd`/ssh.d
SHARE_FW4EX_LOG=false
PROVIDE_APACHE=true
PROVIDE_SMTP=false
DOCKERIMAGETAG=latest
FW4EX_MASTER_KEY=/root/.ssh/fw4excookie.insecure.key
source config.sh

# Does the container needs to know the FW4EX master key. This key is
# required for all authenticated requests to the FW4EX machinery. This
# key is named fw4excookie.insecure.key
if $NEED_FW4EX_MASTER_KEY
then
    mkdir -p $SSHDIR/
    if [ -r $FW4EX_MASTER_KEY ]
    then
        cp -f $FW4EX_MASTER_KEY $SSHDIR/
    else
        echo "Cannot find $FW4EX_MASTER_KEY"
        exit 51
    fi
fi

usage () {
    cat <<EOF
Usage: ${0##*/} [option]
  -i        interactive mode, start a bash interpreter
  -s N      stop the container after N seconds
  -n        do not run any setup-*.sh sub-scripts
  -e CMD    run CMD instead of start.sh (and its options) in the container
  -D V=v    exports the variable V with value v in the container
  -o STR    adds STR to the options of start.sh
  -r        refresh docker images
Default option is -s $SLEEP

This script should be run on a Docker host. It installs and starts a
new container. Most of these options (s, i, n)are mainly passed to the
starting script of the container. Option -e imposes the starting script.
EOF
}

START_FLAGS=
REFRESH_DOCKER_IMAGES=false
while getopts e:s:inD:o:rR opt
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
        D)
            START_FLAGS="$START_FLAGS -D $OPTARG"
            ;;
        o)
            # additional flags for start.sh in the container
            START_FLAGS="$START_FLAGS $OPTARG"
            ;;
        R|r)
            # Force a refresh of the Docker images
            REFRESH_DOCKER_IMAGES=true
            ;;
        \?)
            echo "Bad option $opt"
            usage
            exit 52
            ;;
    esac
done

if ! $INTERACTIVE
then
    if $SETUP
    then
        START_FLAGS="-s $SLEEP $START_FLAGS"
    else
        START_FLAGS="-s $SLEEP $START_FLAGS -n"
    fi
fi

# Prepare ssh keys to let the Docker host access the container via
# ssh. The generated keys are left in the current directory besides
# the current script (install.sh). SSHDIR will become the image from
# which the /root/.ssh/ directory will be created in the container.
# This intermediate copy allows SSHDIR to still belong to the current
# user on the Docker host since, in the container, root will chown
# /root/.ssh in order to comply with sshd policy. Changing ownership
# in the container to root would make SSHDIR belong to root in the
# Docker host and hence would need sudo to be removed.
if ! [ -r ${SSHDIR}/authorized_keys ]
then
    if ! [ -f root_rsa ]
    then
        ssh-keygen -t rsa -N '' -b 2048 \
            -C "root@$HOSTNAME" \
            -f root_rsa
    fi
fi
mkdir -p ${SSHDIR}
cat root_rsa.pub > ${SSHDIR}/authorized_keys
# These are the names expected by Paracamplus/FW4EX/VM.pm          HACK
cp -f root_rsa.pub root.pub
cp -f root_rsa     root
cp -f root root.pub root_rsa* $SSHDIR/
chmod a=r $SSHDIR/*.pub

# Move the keys (mentioned in keys.txt) into SSHDIR:
rm -f while.code 2>/dev/null
if [ -f keys.txt ]
then
    cat keys.txt | while read command keyfile
    do
        case "$command" in
            UNTAR)
                if [ -f "$keyfile" ]
                then
                    echo "Untaring $keyfile..."
                    cp "$keyfile" ${SSHDIR}/ 
                    ( 
                        cd $SSHDIR
                        tar xzf $keyfile --overwrite
                    )
                else
                    echo "Missing file $keyfile"
                    echo 57 > while.code
                    exit 57
                fi
                ;;
            FILE)
                if [ -f "$keyfile" ]
                then
                    echo "Copying $keyfile..."
                    cp "$keyfile" ${SSHDIR}/ || exit 57
                else
                    echo "Missing file $keyfile"
                    echo 57 > while.code
                    exit 57
                fi
                ;;
            *)
                echo "Unrecognized command $command"
                echo 53 > while.code
                exit 53
                ;;
            esac
    done
fi

[ -r while.code ] && exit $(cat while.code)

for f in install-*.sh
do
    if [ -f $f ]
    then
        echo "Sourcing $f"
        source $f 
        status=$?
        if [ $status -gt 0 ]
        then 
            echo "Failed to run $f ($status)"
            exit $status
        fi
    fi
done

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
    exit 54
fi

if ${REFRESH_DOCKER_IMAGES}
then
    echo "*** Download fresh copy of ${DOCKERIMAGE}"
    docker pull ${DOCKERIMAGE}:${DOCKERIMAGETAG}
elif docker images | grep -E -q "^${DOCKERIMAGE} *${DOCKERIMAGETAG}"
then 
    echo "*** Using current local copy of ${DOCKERIMAGE}"
else
    echo "*** Download fresh copy of ${DOCKERIMAGE}:${DOCKERIMAGETAG}"
    docker pull ${DOCKERIMAGE}:${DOCKERIMAGETAG}
fi

# Remove all related containers:
( docker stop ${DOCKERNAME} 
  docker rm   ${DOCKERNAME} ) 2>/dev/null &
( docker stop tmp${DOCKERNAME}
  docker rm tmp${DOCKERNAME} ) 2>/dev/null &
( docker stop tmpi${DOCKERNAME}
  docker rm tmpi${DOCKERNAME} ) 2>/dev/null &
wait

if $DEBUG
then
    ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS -v /dev/log:/dev/log "
fi

# Determine the IP of the Docker host as will be seen by the container.
hostip () {
    # HACK HACK HACK HACK HACK HACK HACK HACK HACK
    echo 172.17.42.1
}
ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS --add-host=docker:$(hostip)"

# Cleanup
( rm -f docker.cid  &
  rm -f docker.ip   &
  rm -f docker.tag  &
  rm -f rootfs      &
) 2>/dev/null

if $INTERACTIVE
then
    if [ -n "$COMMAND" ]
    then 
        echo "Run a specific command within the container and exit"
        docker run --rm \
            ${ADDITIONAL_FLAGS} \
            -p "127.0.0.1:${HOSTSSHPORT}:22" \
            --name=tmp${DOCKERNAME} -h $HOSTNAME \
            -v ${SSHDIR}:/root/ssh.d \
            ${DOCKERIMAGE} \
            $COMMAND
    else
        echo "Run a single bash (without daemon) in the container then exit"
        docker run -it \
            ${ADDITIONAL_FLAGS} \
            -p "127.0.0.1:${HOSTSSHPORT}:22" \
            --name=tmpi${DOCKERNAME} -h $HOSTNAME \
            -v ${SSHDIR}:/root/ssh.d \
            ${DOCKERIMAGE} 
    fi
    exit $?
else
    echo "Start the container with all its daemons"
    CID=$(docker run -d \
        ${ADDITIONAL_FLAGS} \
        -p "127.0.0.1:${HOSTSSHPORT}:22" \
        --name=${DOCKERNAME} -h $HOSTNAME \
        -v ${SSHDIR}:/root/ssh.d \
        ${DOCKERIMAGE} \
        bash -x /root/RemoteScripts/start.sh $START_FLAGS )
    CODE=$?
    [ "$CODE" -ne 0 ] && exit $CODE
fi

if [ -z "$CID" ]
then 
    echo "Starting Docker container $DOCKERNAME failure!"
    exit 55
fi

# Make smoothless the connection between the Docker host and the container:
echo $CID > docker.cid
# Record the version of the Docker image:
docker ps -l | awk '/paracamplus/ {print $2}' > docker.tag
# BUG in Docker 1.3.2: don't use . as target of 'docker cp':
docker cp ${CID}:/etc/ssh/ssh_host_ecdsa_key.pub `pwd`/
KEY="$(cat ./ssh_host_ecdsa_key.pub)"
KEY="${KEY%root@*}"
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID})
if [ -z "$IP" ]
then
    echo "No IP allocated!"
    exit 56
fi
echo $IP > docker.ip
touch $HOME/.ssh/known_hosts
sed -i -e "/^$IP/d" $HOME/.ssh/known_hosts
echo "$IP $KEY"  >> $HOME/.ssh/known_hosts
if [ "$USER" = root ]
then
    echo "$IP $KEY"  >> /etc/ssh/ssh_known_hosts
fi
if [ -d /var/lib/docker/devicemapper/mnt/$CID/rootfs/ ]
then
    ln -sf /var/lib/docker/devicemapper/mnt/$CID/rootfs .
elif [ -d /var/lib/docker/aufs/mnt/$CID/ ]
then
    ln -sf /var/lib/docker/aufs/mnt/$CID/ rootfs
fi

if [ -n "${HOSTSSHPORT}" ]
then
    sed -i -e "/^\[$IP\]:${HOSTSSHPORT}/d" $HOME/.ssh/known_hosts
    echo "[$IP]:$HOSTSSHPORT $KEY"  >> $HOME/.ssh/known_hosts
fi
# To avoid a question for the first access to the container:
touch $HOME/.ssh/config
sed -i -e '/NoHostAuthenticationForLocalhost/d' $HOME/.ssh/config
echo 'NoHostAuthenticationForLocalhost yes' >> $HOME/.ssh/config

# Allow the container to send mails. This tunnel can only be setup by
# the Docker host so we must wait for the container's sshd daemon to
# be ready.
if ${PROVIDE_SMTP}
then
    # Leave time for the container to start sshd:
    # @bijou: 3-7 seconds
    for t in $(seq 1 30)
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
    # Check that the tunnel is open ?
    sleep 2
    CMDPATTERN="25:127.0.0.1:25 +-p ${HOSTSSHPORT}"
    if ps -C ssh -o pid,cmd | grep -E "$CMDPATTERN"
    then :
    else
        echo "Cannot open tunnel 25:127.0.0.1:25"
        exit 59
    fi
fi

# Allow the container to open a tunnel to the Docker host.
#NOTA: this code should be unified with PROVIDE_SMTP
if [ -n "${PROVIDE_TUNNEL}" ]
then
    # Leave time for the container to start sshd:
    # @bijou: 3-7 seconds
    for t in $(seq 1 30)
    do
        sleep 1
        echo "Trying($t) to SSH the container"
        if ssh -p ${HOSTSSHPORT} -i ./root_rsa root@127.0.0.1 hostname
        then
            nohup ssh -nNC -o TCPKeepAlive=yes \
                -i ./root_rsa \
                -R ${PROVIDE_TUNNEL}:127.0.0.1:${PROVIDE_TUNNEL} \
                -p ${HOSTSSHPORT} root@127.0.0.1 &
            break
        fi
    done
    # Check that the tunnel is open ?
    sleep 2
    CMDPATTERN="${PROVIDE_TUNNEL}:127.0.0.1:${PROVIDE_TUNNEL} +-p ${HOSTSSHPORT}"
    if ps -C ssh -o pid,cmd | grep -E "$CMDPATTERN"
    then :
    else
        echo "Cannot open tunnel ${PROVIDE_TUNNEL}:127.0.0.1:${PROVIDE_TUNNEL}"
        exit 59
    fi
fi

# Install specific files on the Docker host:
if [ "$USER" = root ]
then
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
            # the content of qnc-docker.sh must be fixed before         FIXME
            rsync -avu etc/init.d/qnc-docker.sh \
                /etc/init.d/qnc-docker-$HOSTNAME.sh
            rm -f /etc/init.d/qnc-docker.sh
            update-rc.d qnc-docker-$HOSTNAME.sh defaults
        )
    fi
fi

docker ps -l

# Give time for sshd and other daemons to be up and running in the container:
sleep 10

# Perform some check on the Docker container:
for f in check-??-*.sh
do
    if [ -f $f ]
    then
        echo "Sourcing $f"
        source $f 
        status=$?
        if [ $status -gt 0 ]
        then 
            echo "Failed check $f ($status), stopping Docker container"
            docker stop ${DOCKERNAME}
            exit $status
        fi
    fi
done

echo "Docker container ${DOCKERNAME} ready"

# end of install.sh
