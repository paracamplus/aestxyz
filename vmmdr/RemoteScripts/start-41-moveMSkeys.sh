#! /bin/bash
# Runs as root in the Docker container, install private keys to communicate
# with the Marking Slave.

mkdir -p /home/fw4ex/.ssh
    
# Get private key to ssh the vmms container for user fw4ex:
rsync -au /root/.ssh/ /home/fw4ex/.ssh/

# Substitute
( 
    cd /home/fw4ex/.ssh/
    rm -f root*
    cp -p vmms_rsa     root_rsa
    cp -p vmms_rsa.pub root_rsa.pub
    cp -p vmms_rsa     root
    cp -p vmms_rsa.pub root.pub
)

# Fix ownership
chown -R fw4ex: /home/fw4ex/.ssh/

# Improve known_hosts of user fw4ex in order to allow copying
# config.sh files towards the MS.
KEY="$(cat /home/fw4ex/.ssh/vmms_host.pub)"
KEY="${KEY%root@*}"
#IP="$(cat /home/fw4ex/.ssh/vmms.ip)"
#echo "$IP $KEY"  >> /etc/ssh/ssh_known_hosts
echo "[127.0.0.1]:58022 $KEY"  >> /etc/ssh/ssh_known_hosts
if ssh-keygen -f /etc/ssh/ssh_known_hosts \
    -F '[127.0.0.1]:58022' | grep -iq found
then :
else
    echo "/etc/ssh/ssh_known_hosts not filled"
    exit 40
fi

# end of start-41-moveMSkeys.sh
