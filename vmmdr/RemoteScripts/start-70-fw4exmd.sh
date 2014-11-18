#! /bin/bash 
# Fix everything needed to run qnc-fw4ex.sh in the Marking Driver

chown fw4ex: /opt/$HOSTNAME/fw4excookie.insecure.key
chmod 444    /opt/$HOSTNAME/fw4excookie.insecure.key

(
    mkdir -p /opt/$HOSTNAME/Servers/.ssh
    cd /opt/$HOSTNAME/Servers/.ssh/ && \
    tar xzf /root/.ssh/keys.tgz --overwrite
)

rm -f /var/log/fw4ex/qnc-fw4ex.log.*
rm -f /var/log/fw4ex/md/md.log.*

mkdir -p /var/www/s.paracamplus.com/s
mkdir -p /var/www/s.paracamplus.com/e
mkdir -p /var/www/s.paracamplus.com/b
chown -R fw4ex: /var/www/s.paracamplus.com/

if [ -f /root/RemoteScripts/booted ]
then
    echo "Default configuration for qnc-fw4ex.sh:"
    cat /etc/default/fw4ex
    /etc/init.d/qnc-fw4ex.sh start
fi

# end of start-70-fw4exmd.sh
