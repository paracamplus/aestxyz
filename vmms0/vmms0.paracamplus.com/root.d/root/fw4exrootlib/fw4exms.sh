#! /bin/bash

# This script is started on an Marking Driver and inspect the (today
# single) related Marking Slave. 

VERBOSE=false
SSHKEY=/root/.ssh/lxc.insecure.key
SSHIP=172.16.83.2
SSH="ssh -i $SSHKEY root@$SSHIP "

# return to root's HOME directory where is fw4exrootlib/
cd ${0%/*}/

usage () {
    local msg="$*"
    cat <<EOF
${0#*/} [options] command [arguments]
This command is run on a Marking Driver to inspect a Marking Slave.
Options are 
   -v        be verbose
   -ip IP    IP of the Marking Slave (by default $SSHIP)
   -key file file holding an ssh private key towards root@$SSHIP 
             (default is $SSHKEY)
command may be
   help     this documentation
   info     describes the marking slave (verbosity possible)
   persons  list current authors, students
   log      tail the marking slave's log
   cleanup  reset the marking slave
   connect  ssh to $SSHIP
EOF
    if [ -n "$msg" ]
    then 
        echo $msg
        exit 2
    fi        
}

info () {
    echo "===ssh root@$SSHIP hostname, date"
    $SSH hostname
    echo `$SSH date` "(here: $(date))"
    if $VERBOSE
    then
        echo "===ssh root@$SSHIP Marking Slave state"
        $SSH ls /home/md/*.d/
        $SSH ls /home/md/cache/*.d/
    fi
}

persons () {
    echo "===Authors, students on MS"
    $SSH ls /home/
}

log () {
    echo "===tail of /var/log/fw4ex/err.log"
    $SSH tail -f /var/log/fw4ex/err.log
}

cleanup () {
     echo "===Cleanup exercises, students, log"
    $SSH /root/fw4exrootlib/clear-cached-exercises.sh
    $SSH /root/fw4exrootlib/clear-students.sh
    $SSH /root/fw4exrootlib/clear-log.sh
}

connect () {
    $SSH -t
}

while [ $# -gt 0 ]
do
    case "$1" in
        -v)
            VERBOSE=true
            shift
            ;;
        -ip)
            SSHIP=$2
            SSH="ssh -i $SSHKEY root@$SSHIP "
            shift 2
            ;;
        -key)
            SSHKEY=$2
            SSH="ssh -i $SSHKEY root@$SSHIP "
            shift 2
            ;;
        -h|help)
            usage
            exit
            ;;
        info)
            info
            exit
            ;;
        students|authors|persons)
            persons
            exit
            ;;
        connect)
            connect
            exit
            ;;
        log)
            log
            exit
            ;;
        cleanup)
            cleanup
            exit
            ;;
        *)
            usage "No such command $1"
            exit 1
            ;;
    esac
done


# end of fw4exms.sh
