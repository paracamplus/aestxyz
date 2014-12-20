#! /bin/bash -e
# Start all daemons in the Docker container.
# Errors are signalled with a 4x code.

SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
INTERACTIVE=false
SETUP=true
COMMAND=bash

# Docker mounts private information in /root/ssh.d/ that must be
# copied in /root/.ssh/. Since ownership and right of /root/.ssh/ will
# be fixed by the container (to belong to root and be compatible with
# sshd policy), this allows ssh.d to stay as a regular directory on
# the Docker host that can be removed without help of sudo. The copy
# must be done immediately so we may ssh the container.

mkdir -p /root/.ssh
rsync -avu /root/ssh.d/ /root/.ssh/

usage () {
    cat <<EOF
Usage: ${0##*/} [option]
  -s N      sleep N seconds then stop the container
  -i        interactive mode, start a bash interpreter
  -n        interactive mode, start a bash interpreter but do not
            run any setup-*.sh sub-scripts
Default option is -s $SLEEP

This script defines what the container will run when started. This
is the equivalent of the init process in a bootable Linux.
EOF
}

while getopts s:inD:c: opt
do
    case "$opt" in
        s)
            # Exit from the container after that number of seconds:
            SLEEP=$OPTARG
            SETUP=true
            INTERACTIVE=false
            ;;
        i)
            # Start an interactive session (useful for debug):
            SETUP=true
            INTERACTIVE=true
            ;;
        n)
            # Don't run setup-*.sh sub-scripts
            SETUP=false
            INTERACTIVE=true
            ;;
        D)
            eval "export $OPTARG"
            ;;
        c)
            COMMAND="$OPTARG"
            INTERACTIVE=true
            ;;
        \?)
            echo "Bad option $opt"
            usage
            exit 41
            ;;
    esac
done

if $SETUP
then
    chmod a+x ${0%/*}/*.sh
    if [ 1 -le $( ls -1 ${0%/*}/start-*.sh 2>/dev/null | wc -l ) ]
    then 
        for f in ${0%/*}/start-*.sh
        do
            echo "Sourcing $f"
            source $f 
            status=$?
            if [ $status -gt 0 ]
            then 
                echo "Failed to run $f ($status)"
                exit $status
            fi
        done
    fi
fi

echo "========== End of start.sh ============"
if ${INTERACTIVE}
then 
    $COMMAND
else
    sleep $SLEEP
fi

# end of start.sh
