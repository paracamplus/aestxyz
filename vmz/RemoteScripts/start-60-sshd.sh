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
        $f
done

# This will also change the corresponding directory of the Docker host:
chown -R root: /root/.ssh/
chmod -R a-w   /root/.ssh/
chmod go-rw,a+x /root/.ssh

if ! /etc/init.d/ssh start
then 
    echo "Cannot start sshd"
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
