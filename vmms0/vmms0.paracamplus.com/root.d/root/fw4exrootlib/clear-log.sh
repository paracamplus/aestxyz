#! /bin/bash
# This script should be run as root on a marking slave.

source $HOME/fw4exrootlib/commonLib.sh

log ${0##*/}

cd /var/log/fw4ex
mv err.log err.log.$(date +'%FT%T')
echo "Trimmed at $(date)" > err.log
rm -f $( ls -rt1 err.log.* | head -n1 )

# end of clear-log.sh
