#! /bin/bash
# Also start crond in order to limit starman becoming amok

# Check rights and ownership of /root:
chown root:  /root
chmod go-rwx /root

if ! service cron start
then
     tail -n20 /var/log/syslog
fi

# end of start-62-crond.sh
