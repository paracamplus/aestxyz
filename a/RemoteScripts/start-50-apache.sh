#! /bin/bash

rm -rf /var/log/apache2
mkdir /var/log/apache2
chmod 750 /var/log/apache2
chown root:adm /var/log/apache2

if ! /etc/init.d/apache2 start
then
    tail -n20 /var/log/apache2/error.log
fi

# end of start-50.sh
