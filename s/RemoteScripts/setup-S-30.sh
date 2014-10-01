#! /bin/bash

ls -l /var/www/
chown -R $APACHEUSER: /var/www/$HOSTNAME/

# end of setup-S-30.sh
