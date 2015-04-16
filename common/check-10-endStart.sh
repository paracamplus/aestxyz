#! /bin/bash
# This script is run in the Docker host.
# Is start.sh finished ?

if docker logs ${DOCKERNAME} 2>&1 | grep -Eq '^=+ End of start.sh'
then
    true
else
    echo "Docker image ${DOCKERNAME} not ready !?"
    docker logs ${DOCKERNAME} 2>&1 | tail -100
    exit 58
fi

# end of check-10-endStart.sh
