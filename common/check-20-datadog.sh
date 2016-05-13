#! /bin/bash
# This script is run in the Docker host.
# This script needs a HOSTNAME and the path to the analyzer.
# It may be used to analyse an S server with
#    ( cd Docker/a1.paracamplus.com ; HOSTNAME=s1.paracamplus.com ./check-20-datadog.sh ) 
#    ( cd Docker/a.paracamplus.com ; HOSTNAME=s.paracamplus.com ./check-20-datadog.sh ) 

# Trial period exhausted.
exit

REALHOSTNAME=${HOSTNAME}
LOG2DD=./log2dd.pl

echo "Analyzing $HOSTNAME logs with $LOG2DD"

# Deduced variables:
MACHINE=${HOSTNAME%%.*}
DOMAIN=${HOSTNAME#$MACHINE.}
case "$MACHINE" in
    ?)
        MACHINE=${MACHINE}0
        REALHOSTNAME=${MACHINE}.${DOMAIN}
        ;;
esac

( 
    ps --cols 300 -o pid=,args= -C log2dd.pl | \
    grep "hostname $REALHOSTNAME" | \
    while read pid cmd
    do
        kill -9 $pid
    done
)

case "$MACHINE" in
    [aed]?)
        LOGFILE=/var/log/apache2/$HOSTNAME/error.log
        ;;
    s?)
        LOGFILE=/var/log/apache2/$HOSTNAME-access.log
        ;;
    *)
        echo "Unknown type of machine $MACHINE" 1>&2
        exit 55
        ;;
esac

if [ -r $LOGFILE ]
then
    if [ -x "$LOG2DD" ]
    then
        echo "Processing $LOGFILE for DataDog"
        nohup $LOG2DD --datadog \
            --hostname $REALHOSTNAME \
            --file $LOGFILE \
            >> /var/log/log2dd.$REALHOSTNAME 2>&1 &
        sleep 5 # leave time for nohup to start!
    else
        echo "Absent $LOG2DD script!" 1>&2
        exit 55
    fi
else
    echo "Unreadable file: $LOGFILE" 1>&2
    exit 55
fi

# end of check-20-datadog.sh
