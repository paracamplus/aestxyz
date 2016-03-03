#! /bin/bash

cd /root/RemoteScripts

usage () {
    cat <<EOF
Usage: ${0##*/} status|start|stop|restart|watch|install-watch
EOF
}

start () {
    echo "############ START starman #####"  >> /var/log/apache2/error.log
    /root/RemoteScripts/start-55-perlHttpServer.sh
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
    local GROUP=$( top -b -n 1 | /root/RemoteScripts/filterStarman.pl )
    if [ "$GROUP" = '' ]
    then 
        echo "############ CHECK starman #####"  >> /var/log/apache2/error.log
    else {
            echo "############ AMOK starman.sh #####"  
            ps -eo pgrp,pid,pcpu,time,priority,cmd
            echo "############ RESTARTING1 starman at `date` #####"  
        } >> /var/log/apache2/error.log
        /root/RemoteScripts/starman.sh restart
    fi
    # Restart if not running!
    if /root/RemoteScripts/starman.sh status
    then :
    else
        echo "############ RESTARTING2 starman at `date` #####" \
             >> /var/log/apache2/error.log
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

        # top and ps do not display the same %CPU!
        cat >/root/RemoteScripts/filterStarman.pl <<'EOF'
#! /usr/bin/perl
# Input is:
#  ps -eo pgrp,pid,pcpu,time,priority,cmd
# PGRP   PID %CPU     TIME PRI CMD
#    1     1  0.0 00:00:00  20 bash -x /root/RemoteScripts/start.sh -s 315360
#   58    58  0.0 00:00:13  20 starman master --daemonize --listen 0:80 --use
#   58    59  7.2 03:12:17  20 starman worker --daemonize --listen 0:80 --use
#
# top -b -n 1
#   PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
#10191 queinnec  20   0 1107784  47248  13584 S   6.2  0.4 244:10.86 python
#    5 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/0:+
#  PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM    TIME+  COMMAND
#24138 web2user  20   0  202m  75m 3092 S   0.0  3.8   0:00.05 starman master
#24139 web2user  20   0  202m  78m 5852 S   0.0  3.9   0:00.21 starman worker

while ( <> ) {
  next unless / starman/;
# if ( /^\s*(\d+)\s+(\d+)\s+(\d*[.]\d*)\s+((\d*):(\d+):(\d+))\s*/ ) {
#   my ($pgrp, $pid, $cpu, $time, $h, $m, $s) = ($1, $2, $3, $4, $5, $6);
  if ( /^\s*(\d+)\s+(\w+)\s+(\d+)\s+(\d+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\d*[.]\d*)\s+(\d*[.]\d*)\s+(((\d*):)?(\d+):(\d+)([.]\d*)?)\s+(.*)$/ ) {
    my ($pid,$user,$pr,$ni,$virt,$res,$shr,$S,$cpu,$mem,$time,$h,$m,$s,$command) = 
      ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $13, $14, $15, $17);
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
