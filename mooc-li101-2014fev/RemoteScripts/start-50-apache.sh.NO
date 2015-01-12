#! /bin/bash

if [ -d /var/log/apache2 ]
then 
    logrotate --force /etc/logrotate.d/apache2 
else 
    mkdir -p /var/log/apache2
    chmod 750 /var/log/apache2
    chown root:adm /var/log/apache2
fi

if ! /etc/init.d/apache2 start
then
    tail -n20 /var/log/apache2/error.log
fi

# end of start-50.sh
