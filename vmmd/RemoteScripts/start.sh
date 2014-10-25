#! /bin/bash -e
# Start all daemons in the Docker container.
# Errors are signalled with a 4x code.

SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
SETUP=true

usage () {
    cat <<EOF
Usage: ${0##*/} [-s N] [-n]
  -s N      sleep N seconds then stop the container
  -n        do not run any setup-*.sh sub-scripts
Default option is -s $SLEEP

This script defines what the container will run when started. This
is a rough equivalent of the init process in a bootable Linux.
EOF
}

while getopts s:n opt
do
    case "$opt" in
        s)
            # Exit from the container after that number of seconds:
            SLEEP=$OPTARG
            SETUP=true
            ;;
        n)
            # Don't run setup-*.sh sub-scripts
            SETUP=false
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
    if [ 1 -le $( ls -1 ${0%/*}/start-*.sh 2>/dev/null | wc -l ) ]
    then 
        for f in ${0%/*}/start-*.sh
        do
            echo "Sourcing $f"
            source $f 
            status=$?
            if [ $status -gt 0 ]
            then exit $status
            fi
        done
    fi
fi

sleep $SLEEP

# end of start.sh
