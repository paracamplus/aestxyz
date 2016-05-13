#! /bin/bash
# Obsolete: see start-62-crond.sh

if ! /etc/init.d/cron start
then
    tail -n20 /var/log/syslog
fi

# end of start-29-crond.sh
