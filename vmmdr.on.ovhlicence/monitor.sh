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

SUDO=sudo
may_sudo () {
    if ! sudo hostname
    then
        echo "WARNING: Cannot sudo!"
        SUDO=
    fi
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
      rm docker.{cid,ip} rootfs \
         root root.pub root_rsa root_rsa.pub \
         ssh_host_ecdsa_key.pub nohup.out ) 2>/dev/null
    ( cd vmmdr.paracamplus.com
      rm docker.{cid,ip} rootfs \
         root root.pub root_rsa root_rsa.pub \
         ssh_host_ecdsa_key.pub nohup.out ) 2>/dev/null
    $SUDO rm -rf $(find . -type d -name ssh.d -o -name log.d 2>/dev/null)
}

dist () {
    stop
    clean
    local OUT=$(date -u +vmmdr+vmms-%FT%H%M%S.tgz)
    #trap "rm $OUT" 0
    tar czhf $OUT --exclude='*~' \
        monitor.sh \
        vmms.paracamplus.com/ \
        vmmdr.paracamplus.com/ 
    cryptFile `pwd`/$OUT `pwd`/vmmdr+vmms.public.key `pwd`/$OUT.bf
    rm -f $OUT
    rsync -avu $OUT.bf info.fw4ex.org:/var/www/info.fw4ex.org/vmmdr+vmms/
# create latest link........
    # This will push all the tagged images with these names:
    docker push paracamplus/aestxyz_vmms
    docker push paracamplus/aestxyz_vmmdr
}

cryptFile () {
    local INFILE="$1"
    local PUBKEY="$2"
    local OUTFILE="$3"
    local DIR=$(mktemp -d -p $HOME XXXsslXXXX)
    trap "rm -rf $DIR" 0
    (
        cd $DIR
        dd if=/dev/random of=secretkey bs=1k count=1 2>/dev/null
        # Crypt INFILE with a random key (kept in secretkey):
        openssl enc -blowfish -pass 'file:secretkey' < $INFILE > all.bf
        # Crypt the secretkey with a public key:
        openssl rsautl -encrypt \
            -inkey $PUBKEY -pubin \
	    -in secretkey -out secretkey.rsa
        # Pack these two files into OUTFILE:
        tar czf $OUTFILE secretkey.rsa all.bf
        cd && rm -rf $DIR
    )
}

decryptFile () {
    local INURL="$1"
    local PRIVATEKEY="$2"
    local OUTFILE="$3"
    export LANG=C
    local DIR=$(mktemp -d -p $HOME XXXsslXXXX)
    trap "rm -rf $DIR" 0
    (
        cd $DIR
        wget -q -O got.tgz $INURL
        # Expand the tgz into secretkey.rsa and all.bf:
        tar xzf got.tgz
        # Decrypt the secretkey:
        openssl rsautl -decrypt \
	    -inkey $PRIVATEKEY \
	    -in secretkey.rsa -out secretkey
        # then decrypt all.bf:
        openssl enc -d -blowfish -pass 'file:secretkey' \
	    -in all.bf -out $OUTFILE
        cd && rm -rf $DIR
    )
}

# This should run on the host where we want to install the Docker containers.
install () {
    mkdir -p Docker
    decryptFile 'http://info.fw4ex.org/vmmdr+vmms/latest' \
        ${HOME}/.ssh/vmmdr+vmms.private.key \
        `pwd`/Docker/vmmdr+vmms.tgz
    exit 1
    #rsync -avuL vmmdr.on.ovhlicence/ fw4ex@ns327071.ovh.net:Docker/
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
    dist)
        dist
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
