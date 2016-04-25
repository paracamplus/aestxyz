#! /bin/bash
# Also start sshd in order to introspect the container with ssh.
# This script is adapted from start-60-sshd.sh for a marking driver.

# Check rights and ownership of /root:
chown root:  /root
chmod go-rwx /root

for f in /etc/ssh/ssh*_config
do
    sed -i.bak \
        -e 's/^# *GSSAPIAuthentication no/GSSAPIAuthentication no/' \
        -e '/GSSAPIAuthentication *yes/d' \
        $f
done
echo 'HashKnownHosts no' >> /etc/ssh/ssh_config

# This will also change the corresponding directory of the Docker host:
mkdir -p /root/.ssh/
chown -R root: /root/.ssh/
chmod -R a-w   /root/.ssh/
chmod go-rw,a+x /root/.ssh

if [ -f /root/RemoteScripts/knownhosts.txt ]
then
    cat /root/RemoteScripts/knownhosts.txt >> /etc/ssh/ssh_known_hosts
    chmod a=r /etc/ssh/ssh_known_hosts
fi

# Copy this private key to allow the MD to access s.paracamplus.com 
mkdir -p /home/md/.ssh
cp -p /root/.ssh/fw4ex     /home/md/.ssh/
cp -p /root/.ssh/fw4ex.pub /home/md/.ssh/
cp -p /root/.ssh/saver2_rsa     /home/md/.ssh/
cp -p /root/.ssh/saver2_rsa.pub /home/md/.ssh/

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
    ls -l /root/.ssh/fw* /root/.ssh/sav*
    ls -l /root/.ssh/ | head -n5
    if [ -r /root/.ssh/authorized_keys ]
    then
        echo "Content of /root/.ssh/authorized_keys"
        cat /root/.ssh/authorized_keys
    fi
fi 

# end of start-60.sh
