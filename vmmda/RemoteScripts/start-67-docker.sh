#! /bin/bash
# Start a docker server within the container.

end () {
    if ! [ -f /root/RemoteScripts/booted ]
    then
        # See https://github.com/jpetazzo/dind/issues/19
        start-stop-daemon --stop --pidfile "/var/run/docker.pid"
    fi
}
trap "end" 0

rm -f /var/run/docker.pid 2>/dev/null

if ${USE_WRAPDOCKER:-false}
then 
    # Use wrapdocker:
    ( 
        export LOG=file 
        bash -x /usr/local/bin/wrapdocker
    )
else
    # Use the Docker daemon directly:
    if ! /etc/init.d/docker start
    then 
        echo "Cannot start docker"
        exit 45
    fi
    sleep 2
fi

for t in $(seq 1 20)
do
    sleep 1
    echo "Trying to connect to Docker daemon ($t)"
    if docker version > /dev/null 2>&1
    then break
    fi
done
if docker version | grep -q 'Server version'
then :
else
    echo "Could not connect to Docker daemon"
    exit 47
fi

# Prepare stuff in order to start a marking slave container.
# NOTA: /root/Docker/vmms.paracamplus.com/ is the directory holding
#       the install.sh command to install and start the VMMS container.

if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
then
    if [ -d /opt/vmmd.paracamplus.com/Docker ]
    then
        rsync -avuL /opt/vmmd.paracamplus.com/Docker /root/
        chmod u+x /root/Docker/*/*.sh
        chown root: /root/Docker/*/*.sh
    fi
    if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
    then
        echo "Cannot create /root/Docker/vmms.paracamplus.com/"
        exit 46
    fi
    cp /root/.ssh/keys.tgz /root/Docker/vmms.paracamplus.com/
fi

mkdir -p /opt/common-${HOSTNAME#*.}
cp -p /opt/$HOSTNAME/private/fw4excookie.insecure.key \
    /opt/common-${HOSTNAME#*.}/

mkdir -p /root/.ssh
touch /root/.ssh/known_hosts

if [ -f /root/RemoteScripts/booted ]
then
    # Start the Marking slave container:
    rm -rf /var/log/fw4ex/ms
    mkdir -p /var/log/fw4ex/ms
    mkdir -p /home/fw4ex/.ssh
    
    echo "Starting the VMMS container..."
    bash -x /root/Docker/vmms.paracamplus.com/install.sh
    
    # Get private key to ssh the vmms container for user fw4ex:
    cp /root/Docker/vmms.paracamplus.com/root* /home/fw4ex/.ssh/

    # Share the same known hosts:
    cp /root/.ssh/known_hosts /home/fw4ex/.ssh/known_hosts
    chown -R fw4ex: /home/fw4ex/.ssh/

else
    # Around 4G to download!
    echo "Downloading paracamplus/aestxyz_vmms ..."
    docker pull paracamplus/aestxyz_vmms
    # after that, 'end' will stop the Docker daemon (and release /dev/loop*)
fi

# end of start-65-docker.sh
