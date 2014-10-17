#! /bin/bash
# Common library for fw4ex scripts run by students or authors.

if [[ -f /home/fw4exlib/config.sh ]]
then
    # Constants set by md-config.yml:
    source /home/fw4exlib/config.sh
else
    # Default configuration:
    JOB_DIR=/home/md/cache/jobs.d
fi

# NOTA: This should be the same as in SimplisticMarkEngine.pm
# NOTA: This should be the same as in Mlib/fw4exrootlib/commonLib.sh
#JOB_DIR=/home/md/cache/jobs.d

if [ ! -d $JOB_DIR ]
then 
    mkdir -p $JOB_DIR
fi

# end of commonLib.sh
