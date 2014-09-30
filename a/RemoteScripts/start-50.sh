#! /bin/bash

rm -rf /var/log/apache2
mkdir /var/log/apache2
chmod 750 /var/log/apache2
chown root:adm /var/log/apache2

/etc/init.d/apache2 start

# end of start-50.sh
