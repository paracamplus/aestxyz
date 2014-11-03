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

if /etc/init.d/docker status | grep running
then 
    echo "Docker is already running"
elif ${USE_WRAPDOCKER:-false}
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
    exit 49
fi

# Prepare stuff in order to start a marking slave container:

if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
then
    if [ -d /opt/vmmd.paracamplus.com/Docker ]
    then
        cp -rp /opt/vmmd.paracamplus.com/Docker /root/
        chmod u+x /root/Docker/*/*.sh
        chown root: /root/Docker/*/*.sh
    fi
    if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
    then
        echo "Missing /root/Docker/vmms.paracamplus.com/"
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
    # chown ?
    
    # Make keys to access vmms readable from user fw4ex which runs md-start
    mkdir -p /home/ms/.ssh
    cp -p /root/Docker/vmmd.paracamplus.com/root* /home/ms/.ssh/
    chmod 700 /home/ms/.ssh/root*
    chown -R fw4ex: /home/ms/
    #echo "SSHDIR=/home/ms/.ssh" >> /root/Docker/vmms.paracamplus.com/config.sh

    bash -x /root/Docker/vmms.paracamplus.com/install.sh

else
    # Around 4G to download!
    echo "Downloading paracamplus/aestxyz_vmms ..."
    docker pull paracamplus/aestxyz_vmms
    # after that, 'end' will stop the Docker daemon.
fi

# end of start-65-docker.sh
