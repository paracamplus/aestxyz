#! /bin/bash 
# Fix everything needed to run qnc-fw4ex.sh in the Marking Driver

chown fw4ex: /opt/$HOSTNAME/fw4excookie.insecure.key
chmod 444    /opt/$HOSTNAME/fw4excookie.insecure.key

(
    mkdir -p /opt/$HOSTNAME/Servers/.ssh
    cd /opt/$HOSTNAME/Servers/.ssh/ && \
    tar xzf /root/.ssh/keys.tgz
)

rm -f /var/log/fw4ex/qnc-fw4ex.log.*
rm -f /var/log/fw4ex/md/md.log.*

if [ -f /root/RemoteScripts/booted ]
then
    /etc/init.d/qnc-fw4ex.sh start
fi

# end of start-70-fw4exmd.sh
