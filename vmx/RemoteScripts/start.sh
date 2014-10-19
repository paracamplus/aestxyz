#! /bin/bash -e
# Start all daemons in the Docker container.
# Errors are signalled with a 4x code.

SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))
INTERACTIVE=false

while getopts s:i opt
do
    case "$opt" in
        s)
            # Exit from the container after that number of seconds:
            SLEEP=$OPTARG
            ;;
        i)
            # Start an interactive session (useful for debug):
            INTERACTIVE=true
            ;;
        \?)
            echo "Bad option $opt"
            exit 41
            ;;
    esac
done

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

if ${INTERACTIVE}
then 
    bash -i
else
    sleep $SLEEP
fi

# end of start.sh
