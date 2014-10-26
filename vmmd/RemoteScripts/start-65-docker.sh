#! /bin/bash
# Start a docker server within the container.

if ! /etc/init.d/docker start
then 
    echo "Cannot start docker"
    exit 45
fi
sleep 2

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

if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
then
    if [ -d /opt/vmmd.paracamplus.com/Docker ]
    then
        mv /opt/vmmd.paracamplus.com/Docker /root/
        chmod u+x /root/Docker/*/*.sh
        chown root: /root/Docker/*/*.sh
    fi
    if ! [ -d /root/Docker/vmms.paracamplus.com/ ]
    then
        echo "Missing /root/Docker/vmms.paracamplus.com/"
        exit 46
    fi
fi

mkdir -p /opt/common-paracamplus.com
cp -p /opt/$HOSTNAME/private/fw4excookie.insecure.key \
    /opt/common-${HOSTNAME#*.}/

mkdir -p /root/.ssh
touch /root/.ssh/known_hosts

if [ -f /root/RemoteScripts/booted ]
then
    bash -x /root/Docker/vmms.paracamplus.com/install.sh
else
    # Around 4G to download!
    echo "Downloading paracamplus/aestxyz_vmms ..."
    docker pull paracamplus/aestxyz_vmms
    # See https://github.com/jpetazzo/dind/issues/19
    start-stop-daemon --stop --pidfile "/var/run/docker.pid"
fi

# end of start-65-docker.sh
