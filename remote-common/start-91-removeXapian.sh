#! /bin/bash
# Hack! The script apt-xapian-index runs every sunday at 7:47 in every
# docker container and eats the total CPU. The corresponding package should
# be removed long before rather than being made pointless afterwards.

if [ -f /etc/cron.weekly/apt-xapian-index ]
then
    if ! dpkg -P apt-xapian-index python-xapian 2>/dev/null
    then 
        echo "Problem while removing apt-xapian-index python-xapian"
        rm -f /etc/cron.weekly/apt-xapian-index
    fi
fi

true

# end of start-91-removeXapian.sh
