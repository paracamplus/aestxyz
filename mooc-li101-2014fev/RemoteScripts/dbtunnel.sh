#! /bin/bash
#
# Open a tunnel towards the central database and try to keep it available.

# Insert public key of the DB server in order to avoid a question.
# ssh-keygen -t ecdsa -N '' -b 521 -C "dbuser@paracamplus.com" -f dbuser_ecdsa
mkdir -p /root/.ssh
touch /root/.ssh/known_hosts
if ! grep -q 'db.paracamplus.com' < /root/.ssh/known_hosts
then
    cat >>/root/.ssh/known_hosts <<EOF
db.paracamplus.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzcR6m0oqAcjmetHswKMaumD3Bp4cf63svOYVc4sxE/TC0cV4DJ0XBZNHwekzF8nTL+gaj63VFNzvNkuWQvmQBGKbN2lXKfKlNmOhpBuIfVHuqWx+Q0R9BoATV841+JA/LZrfR2NmWDQ9k7G8ieQ9tKeH5YU54wfv+XcF1vUAhTJpttVa6vkicfxgCx6/C0BGa7iYMSp0yW2qt0HikoelfZmCLGaXo9DBfvWcSuSyMBZxHV8qk97GD3YxrlPDG08gSWnldHh9Lp1y2Obd5CSC23z7ZzUd4jD6g8x5G4OCkkDJpTKSQPtvM8L1SUvWZJsT15sMS6sReCYHlgkBUHaOWQ==
EOF
fi

# Rectify if need be the rights of the private key of dbuser, the 
# identity with which we connect 
if [ -r /root/.ssh/dbuser_ecdsa ]
then 
    mkdir -p /opt/$HOSTNAME/
    cp /root/.ssh/dbuser_ecdsa /opt/$HOSTNAME/
else
    echo "Missing /root/.ssh/dbuser_ecdsa"
    exit 46
fi
chmod 400 /opt/$HOSTNAME/dbuser_ecdsa

DBHOST=db.paracamplus.com
LOG=/var/log/apache2/$HOSTNAME/dbtunnel.log
PIDFILE1=/var/run/start-dbtunnel.pid
PIDFILE2=/var/run/ssh-dbtunnel.pid
SLEEPTIME=61
REMOTEUSER=dbuser
AVAILABLE=false
VERBOSE=true

log () {
    if $VERBOSE
    then
        echo "$@"
    fi
}

# Checks whether the DB server is alive
is_alive () {
    ping -q -c 2 -w 3 $DBHOST >/dev/null
}

# Checks whether the DB server may be reached via ssh
is_sshable () {
    ssh -i /opt/$HOSTNAME/dbuser_ecdsa \
        $REMOTEUSER@$DBHOST psql -l
}

# Return a code telling if a network change occurred.
availability_changed_to () {
    local STATUS=$1
    if [[ $AVAILABLE = $STATUS ]]
    then
        # No change!
        return 1
    else
        AVAILABLE=$STATUS
        if $AVAILABLE
        then log "Found dbhost $DBHOST on $(date)"
        else log "Lost  dbhost $DBHOST on $(date)"
        fi
        return 0
    fi
}

cleanup () {
    kill_previous_tunnels 2>/dev/null
    kill_previous_scripts 2>/dev/null
}

kill_previous_scripts () {
    local PIDS="$(ps -C ${0%%*/} -opid,cmd | \
                  sed -re 's/([0-9]+) .*$/\1/' )"
    if [ -n "$PIDS" ]
    then
        log "Killing old start processes $PIDS"
        kill -9 $PIDS >/dev/null 2>&1
    fi
    rm -f $PIDFILE1 2>/dev/null
}

kill_previous_tunnels () {
    local PIDS="$(ps -C ssh -opid,cmd | \
                  grep $DBHOST | \
                  sed -re 's/([0-9]+) .*$/\1/' )"
    if [ -n "$PIDS" ]
    then
        log "Killing old processes $PIDS"
        kill -9 $PIDS >/dev/null 2>&1
    fi
    rm -f $PIDFILE2 2>/dev/null
}

open_tunnel () {
    kill_previous_tunnels 2>/dev/null
    nohup ssh -nNC -o TCPKeepAlive=yes \
        -L 5432:127.0.0.1:5432 \
        -i /opt/$HOSTNAME/dbuser_ecdsa \
        $REMOTEUSER@$DBHOST &
    echo $! > $PIDFILE2
    sleep 2
}

state () {
    if [[ -f $PIDFILE1 ]]
    then 
        if ps -p $(cat $PIDFILE1) >/dev/null
        then 
            echo "the tunnel monitoring should be running $(cat $PIDFILE1)"
        fi
    fi
    if [[ -f $PIDFILE2 ]]
    then
        if ps -p $(cat $PIDFILE2) >/dev/null
        then 
            echo "The tunnel should be running $(cat $PIDFILE2)"
        fi
    fi
    ps -opid,cmd | grep $DBHOST | grep -v grep
}

watch () {
    while true
    do
        if is_alive $DBHOST
        then
            if is_sshable $DBHOST
            then
                if availability_changed_to true
                then
                    open_tunnel
                fi
            else
                log "Cannot ssh towards $DBHOST on $(date)"
            fi
        else
            if availability_changed_to false
            then
                kill_previous_tunnels 2>/dev/null
            fi
        fi
        sleep $SLEEPTIME
    done
}

mkdir -p ${LOG%/*}
touch $LOG
echo $$ >$PIDFILE1

DAEMON=false
while [ $# -gt 0 ]
do
    case "$1" in
        # Options
        -v)
            VERBOSE=true
            ;;
        -s)
            state
            exit
            ;;
        -t)
            open_tunnel
            ;;
        -d) 
            # Runs as a daemon:
            exec 1>$LOG 2>&1
            DAEMON=true
            ;;
        -x)
            # Stops the daemon
            cleanup
            exit
            ;; 
        -h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument '$1' ???"
            exit 47
            ;;
    esac
    shift
done

if $DAEMON
then 
    watch &
else 
    watch
fi

# end of dbtunnel.sh
