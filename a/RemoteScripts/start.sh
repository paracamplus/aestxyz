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
        *)
            echo "Bad option $opt"
            ;;
    esac
done

/etc/init.d/apache2 start

sleep $SLEEP

# end of start.sh
