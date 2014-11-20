#! /bin/bash
# Script to install and run a couple of Docker containers: a Marking
# Driver and a Marking Slave. 

# Goto the directory holding this script: monitor.sh
# It should contain two subdirectories vmm{s,dr}.paracamplus.com/
# with the specific config.sh to install.sh these two containers.
cd ${0%/*}/

usage () {
    cat <<EOF
Usage: ${0##*/} start [-l]
       ${0##*/} connect [-h vmmdr|vmms]
       ${0##*/} log
       ${0##*/} stop
       ${0##*/} clean
       ${0##*/} refresh
       ${0##*/} install -h remote.server [-u user]

Option -l display the log of the Marking Driver
       -h specifies on which host to install the couple of Docker containers
       -u is the account name on this host
EOF
}

SOURCE=http://info.fw4ex.org/VMmdms/latest.tgz.ssl
refresh () {
    #wget $SOURCE
    docker pull paracamplus/aestxyz_vmms
    docker pull paracamplus/aestxyz_vmmdr
}

start () {
    $VERBOSE vmms.paracamplus.com/install.sh
    local CODE=$?
    [ "$CODE" -ne 0 ] && return $CODE
    $VERBOSE vmmdr.paracamplus.com/install.sh
}

show_md_log () {
    while true
    do
        if [ -r vmmdr.paracamplus.com/log.d/md/md.log ]
        then 
            break
        else
            echo "Waiting for md.log to appear..." 1>&2
            sleep 1
        fi
    done
    tail -F vmmdr.paracamplus.com/log.d/md/md.log
}

connect () {
    local vm=$1
    case "$vm" in
        vmms)
            ssh -p 58022 -i vmms.paracamplus.com/root_rsa root@127.0.0.1
            ;;
        vmmd|vmmdr)
            ssh -p 61022 -i vmmdr.paracamplus.com/root_rsa root@127.0.0.1
            ;;
        *)
            echo "Bad VM name $vm"
            exit 13
            ;;
    esac
}

stop () {
    echo "Stopping vmms and vmmdr..."
    ( docker stop vmms  ; docker rm vmms  ) 2>/dev/null &
    ( docker stop vmmdr ; docker rm vmmdr ) 2>/dev/null &
    wait
}

clean () {
    ( cd vmms.paracamplus.com
      rm docker.{cid,ip} \
         root root.pub root_rsa root_rsa.pub \
         ssh_host_ecdsa_key.pub )
    ( cd vmmdr.paracamplus.com
      rm docker.{cid,ip} \
         root root.pub root_rsa root_rsa.pub \
         ssh_host_ecdsa_key.pub )
    sudo rm -rf $(find . -type d -name ssh.d 2>/dev/null)
    sudo rm -rf $(find . -type d -name log.d 2>/dev/null)
}

install () {
    ssh ${USER}@$REMOTE "mkdir -p Docker"
    rsync -avuL ${0} ${USER}@$REMOTE:Docker/
    ssh ${USER}@$REMOTE "mkdir -p Docker/vmms.paracamplus.com"
    rsync -avuL \
        vmms.paracamplus.com/install.sh \
        vmms.paracamplus.com/config.sh \
        ${USER}@$REMOTE:Docker/vmms.paracamplus.com/
    ssh ${USER}@$REMOTE "mkdir -p Docker/vmmdr.paracamplus.com"
    rsync -avuL \
        vmmdr.paracamplus.com/install.sh \
        vmmdr.paracamplus.com/config.sh \
        ${USER}@$REMOTE:Docker/vmmdr.paracamplus.com/
}        

COMMAND="$1"
shift

LOG=false
HOST=no.such.host
USER=${USER:-nobody}
VERBOSE=
while getopts lh:u:v opt
do
    case "$opt" in
        l)
            LOG=true
            ;;
        h)
            REMOTE=$OPTARG
            ;;
        u)
            USER=$OPTARG
            ;;
        v)
            VERBOSE='bash -x'
            ;;
        \?)
            echo "Bad option $opt"
            usage
            exit 11
            ;;
    esac
done

case "$COMMAND" in
    start)
        stop
        clean
        start
        CODE=$?
        [ "$CODE" -ne 0 ] && exit $CODE
        $LOG && show_md_log
        ;;
    stop)
        stop
        ;;
    refresh)
        refresh
        ;;
    clean)
        clean
        ;;
    connect)
        # requires the -h option!
        connect $REMOTE
        ;;
    log)
        show_md_log
        ;;
    install)
        # requires the -h option!
        install
        ;;
    *)
        echo "Unknown command $COMMAND"
        exit 12
        ;;
esac

# end of start.sh
