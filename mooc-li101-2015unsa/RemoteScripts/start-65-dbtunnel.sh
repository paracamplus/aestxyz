#! /bin/bash
# Monitor the tcp connection towards the database (only if not using
# the Postgresql socket). 

if [ -z "$PGWAY" -o "$PGWAY" = viatcp ]
then
    if [ -x ${0%/*}/dbtunnel.sh ]
    then
        ${0%/*}/dbtunnel.sh -d &
    else
        echo "Missing ${0%/*}/dbtunnel.sh"
        exit 48
    fi
fi

# end of start-65-dbtunnel.sh
