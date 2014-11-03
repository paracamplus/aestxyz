#! /bin/bash 
# Fix everything needed for the Marking Slave

if [ -f /opt/$HOSTNAME/fw4excookie.insecure.key ]
then
    chown fw4ex: /opt/$HOSTNAME/fw4excookie.insecure.key
    chmod 444    /opt/$HOSTNAME/fw4excookie.insecure.key
fi

# This will also change the corresponding directory of the Docker host:
chown -R root: /root/.ssh/
chmod -R a-w   /root/.ssh/
chmod go-rw,a+x /root/.ssh

# end of start-71-fw4exms.sh
