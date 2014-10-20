#! /bin/bash
# Runs as root within the container
# It removes old stuff and prepares the container to be archived and ready
# to be installed elsewhere.

aptitude clean
/root/RemoteScripts/cleancpan.sh
rm /tmp/*.jpg          2>/dev/null
rm /tmp/crontab.root   2>/dev/null
rm /tmp/??????????     2>/dev/null
rm /home/fw4ex/bin/echoecho    2>/dev/null

# remove all old logs
( cd /var/log/
  rm -f *.[01]
  rm -f *.[1-9].gz
  rm -f */*.[01]
  rm -f */*.[1-9].gz
) 2>/dev/null

# remove patches
rm -rf /tmp/patches 2>/dev/null

# remove remains from marking exercises
/root/fw4exrootlib/clear-cached-exercises.sh
rm -rf /home/md/exercisedir/*.tgz
rm -rf /home/md/autocheck/*
rm -rf /home/md/incoming/*
rm -rf /home/md/jobs/*.tgz
rm -rf /home/md/results/*
rm -rf /home/md/tmp.*
rm -rf /opt/tmp/*

rm -rf /opt/TGZ 2>/dev/null

rm -f /var/log/apache2/*.log

echo "# trimmed on `date`" > /var/log/fw4ex/err.log
rm -f /var/log/fw4ex/qnc-fw4ex.log.*
rm -f /var/log/fw4ex/md.log.*
echo "# trimmed on `date`" > /var/log/fw4ex/md.log

# Timestamp the creation date to be used by update.sh
date > /root/RemoteScripts/made

# end of cleanup.sh
