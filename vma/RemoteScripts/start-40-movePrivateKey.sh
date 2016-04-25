#! /bin/bash
# in order to not divulge private keys in containers stored on
# DockHub, private keys are kept in a volume on the Docker host and
# mounted when the container is run.

ls -l /root/.ssh/
ls -l /root/ssh.d/
ls -l /usr/local/lib/site_perl/Paracamplus

if [ -r /root/.ssh/fw4excookie.insecure.key ]
then 
    mkdir -p /opt/$HOSTNAME/
    cp -pf /root/.ssh/fw4excookie.insecure.key /opt/$HOSTNAME/
else
    echo "Cannot find fw4excookie.insecure.key"
    exit 43
fi

# end of start-40.sh
