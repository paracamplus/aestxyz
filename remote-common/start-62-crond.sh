#! /bin/bash
# Also start crond in order to limit starman becoming amok

# Check rights and ownership of /root:
chown root:  /root
chmod go-rwx /root

service cron start

# end of start-62-crond.sh
