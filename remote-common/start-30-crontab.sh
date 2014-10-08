#! /bin/bash
# Clean up some temporary directories in the A server.

/etc/init.d/cron start
crontab -l > /root/root.crontab
if ! grep -q prune.pl < /root/root.crontab
then
    chmod a+x /opt/$HOSTNAME/scripts/prune.pl
    echo "1 * * * * cd /opt/$HOSTNAME/ && LANG=C scripts/prune.pl -d jobdir/ -d batchdir/ -d tmpdir/ 2>/dev/null 1>/dev/null" >> /root/crontab
    crontab /root/crontab
fi

# end of start-30-crontab.sh
