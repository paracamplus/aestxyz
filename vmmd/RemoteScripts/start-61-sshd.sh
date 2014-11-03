#! /bin/bash
# Also start sshd in order to introspect the container with ssh.
# This script is adapted from start-60-sshd.sh for a marking driver.

# Check rights and ownership of /root:
chown root:  /root
chmod go-rwx /root

# Don't has hostnames in known_hosts:
for f in /etc/ssh/ssh*_config
do
    sed -i.bak \
        -e 's/^# *GSSAPIAuthentication no/GSSAPIAuthentication no/' \
        -e '/GSSAPIAuthentication *yes/d' \
        $f
done

# Only allow root to ssh the MD container:
echo "AllowUsers root" >>/etc/ssh/sshd_config

# This will also change the corresponding directory of the Docker host:
chown -R root: /root/.ssh/
chmod -R a-w   /root/.ssh/
chmod go-rw,a+x /root/.ssh

if [ -f /root/RemoteScripts/knownhosts.txt ]
then
    cat /root/RemoteScripts/knownhosts.txt >> /etc/ssh/ssh_known_hosts
    chmod a=r /etc/ssh/ssh_known_hosts
fi

# The MD will run under fw4ex account, the MD needs some private keys
# to access *.paracamplus.com so copy these keys into /home/fw4ex/.ssh/
# This directory is only used by the MD (see md-config.yml)
mkdir -p /home/fw4ex/.ssh
cp -p /root/RemoteScripts/fw4ex     /home/fw4ex/.ssh/
cp -p /root/RemoteScripts/fw4ex.pub /home/fw4ex/.ssh/
# Copy this private key to allow the MD to access db.paracamplus.com
cp -p /root/RemoteScripts/saver_dsa     /home/fw4ex/.ssh/
cp -p /root/RemoteScripts/saver_dsa.pub /home/fw4ex/.ssh/
# Copy author* and student* private keys to allow the MD to access the MS:
(
    cd /home/fw4ex/.ssh/
    tar xzf /root/.ssh/keys.tgz
)
# NOTA: Still missing is the private key to access the MS. It will be
# known only after starting the vmms container (see start-67-docker.sh)
chown -R fw4ex: /home/fw4ex/.ssh/

if [ -f /root/RemoteScripts/booted ]
then
    if ! /etc/init.d/ssh start
    then 
        echo "Cannot start sshd"
        exit 44
    fi
fi

#DEBUG
if [ -d /root/.ssh ]
then
    echo "Content of /root/.ssh/"
    ls /root/.ssh/
    if [ -r /root/.ssh/authorized_keys ]
    then
        echo "Content of /root/.ssh/authorized_keys"
        cat /root/.ssh/authorized_keys
    fi
    echo "Content of /home/fw4ex/.ssh/"
    ls /home/fw4ex/.ssh/
fi 

# end of start-60.sh
