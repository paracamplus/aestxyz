#! /bin/bash -e
# Start all daemons in the Docker container.
# Errors are signalled with a 4x code.

SLEEP=$(( 60 * 60 * 24 * 365 * 10 ))

while getopts s: opt
do
    case "$opt" in
        s)
            SLEEP=$OPTARG
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
        source $f || exit 42
    done
fi

sleep $SLEEP

# end of start.sh
