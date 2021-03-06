#! /bin/bash
# Also start sshd in order to introspect the container with ssh.

# Check rights and ownership of /root:
chown root:  /root
chmod go-rwx /root

for f in /etc/ssh/ssh*_config
do
    sed -i.bak \
        -e 's/^# *GSSAPIAuthentication no/GSSAPIAuthentication no/' \
        -e '/GSSAPIAuthentication *yes/d' \
        -e '/HashKnownHosts/d' \
        $f
done
echo 'HashKnownHosts no' >> /etc/ssh/ssh_config
sed -i.bak /etc/ssh/sshd_config \
    -e 's/^.*PermitRootLogin without-password.*$/PermitRootLogin yes/'

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

# With Debian 8.5, failure of sshd returns 0!
/etc/init.d/ssh start & sleep 2
if /etc/init.d/ssh status
then
    :
else
    echo "Cannot start sshd (code $?)"
    exit 44
fi

#DEBUG
if [ -d /root/.ssh ]
then
    echo "Content of /root/.ssh/"
    ls -l /root/.ssh/ | head -n5
    if [ -r /root/.ssh/authorized_keys ]
    then
        echo "Content of /root/.ssh/authorized_keys"
        cat /root/.ssh/authorized_keys
    fi
fi 

# end of start-60.sh
