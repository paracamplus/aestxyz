#! /bin/bash

cd /root/RemoteScripts

usage () {
    cat <<EOF
Usage: ${0##*/} status|start|stop|restart|watch|install-watch
EOF
}

start () {
    ./start-55-perlHttpServer.sh restart
}

# Stop all starman processes
stop () {
    # Look for the master:
    M=$(ps axo pid,cmd | grep 'starman master' | grep -v grep | awk '{print $1}')
    if [ -n "$M" ]
    then
        echo "Kill Starman master $M" 1>&2
        kill -9 $M
    fi

    # Kill the associated workers:
    ps axo pid,cmd | grep 'starman ' | grep -v grep | while read pid cmd
    do
        echo "Kill Starman worker $pid" 1>&2
        kill -9 $pid
    done

    # wait until all workers are gone
    while true
    do
        W=$(ps axo pid,cmd | grep 'starman ' | grep -v grep | wc -l)
        echo "Wait for $W Starman workers death..." 1>&2 
        if [ "$W" -eq 0 ]
        then
            break
        else
            sleep 1
        fi
    done
}

# watch should be run regularly from crontab for instance.
# It will renice the group of starman workers if taking too much CPU.
watch () {
    local GROUP=$( ps -eo pgrp,pid,pcpu,time,priority,cmd | \
        /root/RemoteScripts/filterStarman.pl )
    if [ "$GROUP" = '' ]
    then :
    else {
            echo "############ AMOK starman.sh #####"  
            ps -eo pgrp,pid,pcpu,time,priority,cmd
            echo "############ RESTARTING starman at `date` #####"  
        } >> /var/log/apache2/error.log
        /root/RemoteScripts/starman.sh restart
    fi
    # Restart if not running!
    if /root/RemoteScripts/starman.sh status
    then :
    else
        /root/RemoteScripts/starman.sh restart
    fi
}

# Run watch every minute with root's crontab
install-watch () {
    crontab -l > /root/root.crontab
    if grep -q 'starman.sh watch' < /root/root.crontab
    then :
    else
        echo '* * * * * /root/RemoteScripts/starman.sh watch >/dev/null 2>&1' >> /root/root.crontab
        crontab /root/root.crontab
        cat >/root/RemoteScripts/filterStarman.pl <<'EOF'
#! /usr/bin/perl
# Input is:
#  ps -eo pgrp,pid,pcpu,time,priority,cmd
# PGRP   PID %CPU     TIME PRI CMD
#    1     1  0.0 00:00:00  20 bash -x /root/RemoteScripts/start.sh -s 315360
#   58    58  0.0 00:00:13  20 starman master --daemonize --listen 0:80 --use
#   58    59  7.2 03:12:17  20 starman worker --daemonize --listen 0:80 --use
#
while ( <> ) {
  next unless / starman.*--dae[m]/;
  if ( /^\s*(\d+)\s+(\d+)\s+(\d*[.]\d*)\s+((\d*):(\d+):(\d+))\s*/ ) {
    my ($pgrp, $pid, $cpu, $time, $h, $m, $s) = ($1, $2, $3, $4, $5, $6);
    print $pid if ( $h > 0 or $m > 15 or $cpu > 30 ) 
  } else {
    die "Cannot parse $_";
  }
}
EOF
        chmod a+x /root/RemoteScripts/filterStarman.pl
    fi
}

status () {
    ps -eo pgrp,pid,pcpu,time,priority,cmd | \
        grep -E 'starman worker [-]-daemonize' | \
        tee /tmp/starman.status
    grep -q starman < /tmp/starman.status
}

case "$1" in
    start) 
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    watch)
        watch
        ;;
    install-watch)
        install-watch
        ;;
    status)
        status
        ;;
    *)
        usage
        exit 1
        ;;
esac

# end of starman.sh
