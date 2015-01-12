#! /bin/bash

if [ -x ${0%/*}/dbtunnel.sh ]
then
    ${0%/*}/dbtunnel.sh -d
else
    echo "Missing ${0%/*}/dbtunnel.sh"
    exit 48
fi

# end of start-65-dbtunnel.sh
