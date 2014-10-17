#! /bin/bash
# Common library for fw4ex scripts run by root in the Marking Slave.

PATH=/usr/sbin:/usr/bin:/sbin:/bin

if [[ -f /home/fw4ex/fw4exrootlib/config.sh ]]
then
    # Constants set by md-config.yml:
    source /home/fw4ex/fw4exrootlib/config.sh
else 
    # Default configuration:
    JOB_DIR=/home/md/cache/jobs.d
    USE_EXERCISE_CACHE=false
    EXERCISE_CACHE_DIR=/home/md/cache/exercises.d
    EXERCISE_CACHE_TIMEOUT=3000
    AUTHORS_MAX_NUMBER=99
    STUDENTS_MAX_NUMBER=99
    SPACE_THRESHOLD=50
    k=000
    M=$k$k
    AUTHOR_MAXCPU=90
    AUTHOR_MAXOUT=500$k
    AUTHOR_MAXERR=100$k
    DEBUG_VERBOSITY=0
fi

# Constants
# NOTA: This should be the same as in SimplisticMarkEngine.pm
# NOTA: This should be the same as in Mlib/fw4exlib/commonLib.sh
#JOB_DIR=/home/md/cache/jobs.d

if [ ! -d $JOB_DIR ]
then 
    mkdir -p $JOB_DIR
fi

#USE_EXERCISE_CACHE=true
#USE_EXERCISE_CACHE=false
# NOTA: This should be the same as in SimplisticMarkEngine.pm
#EXERCISE_CACHE_DIR=/home/md/cache/exercises.d

# Cache an exercise for that duration (in seconds). This initial
# duration is adjusted depending on the free space available on the
# disk and on the number of available author's account.
# NOTA: Nagios checks the MD every hour so 3000 allows the exercise
# used by Nagios to disappear.
#EXERCISE_CACHE_TIMEOUT=3000

if [ ! -d $EXERCISE_CACHE_DIR ]
then 
    mkdir -p $EXERCISE_CACHE_DIR
fi
# EXERCISE_CACHE_DIR belongs to root:root
# available-author will create the appropriate sub-directory.

# Don't forget to generate the public keys for these users. See
# Mlib/Init/40users. 99 is the number of predefined authors, 90 is the
# threshold above which we stop caching and clean old exercises.
# Remember that cleaning is done with a 1 minute delay via the crontab.
# NOTA: Use a number in [10 .. 99] only (needed for seq and ssh keys)
#AUTHORS_MAX_NUMBER=99
#STUDENTS_MAX_NUMBER=99

# When the disk is used at more than this percentage, clean it more
# frequently. Of course, this should depend on the size of the disk
# that hold the EXERCISE_CACHE_DIR.
#SPACE_THRESHOLD=50

# Author's limits (FUTURE: should depend on the class of the exercise)
# FUTURE should depend on md-config.yml
#k=000
#M=$k$k
#AUTHOR_MAXCPU=90
#AUTHOR_MAXOUT=500$k
#AUTHOR_MAXERR=100$k

#DEBUG_VERBOSITY=0

# Log via syslog
mkdir -p /var/log/fw4ex

log() {
    logger -i -t FW4EX -- "$@"
    cat >>/var/log/fw4ex/err.log <<EOF
[$(date --utc +'%F %H:%M:%S')] $@
EOF
}

logdebug() {
    if [ $DEBUG_VERBOSITY -gt 0 ]
    then
        cat >>/var/log/fw4ex/err.log <<EOF
DEBUG [$(date --utc +'%F %H:%M:%S')] $@ 
EOF
        sed -e 's/^/**/' >>/var/log/fw4ex/err.log
    else
        cat >/dev/null
    fi
}

# Store every error!
exec 2>>/var/log/fw4ex/err.log

if [[ -f /root/fw4exrootlib/$(hostname).sh ]]
then
    log "Source specific $(hostname) parameters..."
    source /root/fw4exrootlib/$(hostname).sh
fi

# end of commonLib.sh
