#! /bin/bash 
# Fix everything needed to run qnc-fw4ex.sh

chown fw4ex: /opt/$HOSTNAME/fw4excookie.insecure.key
chmod 444    /opt/$HOSTNAME/fw4excookie.insecure.key

(
    mkdir -p /opt/$HOSTNAME/Servers/.ssh
    cd /opt/$HOSTNAME/Servers/.ssh/ && \
    tar xzf /root/.ssh/keys.tgz
)

/etc/init.d/qnc-fw4ex.sh start

# end of start-70-fw4exmd.sh
