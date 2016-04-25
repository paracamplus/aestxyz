#! /bin/bash
# This script is run in the Docker host.

echo "Check whether start.sh is finished ?"

for i in 1 2 3 4 5 6 7 8 9 fin
do
    if [ "$i" = fin ]
    then
        echo "Docker image ${DOCKERNAME} not at all ready !?"
        docker logs ${DOCKERNAME} 2>&1 | tail -100
        exit 58
    else
        # Leave time to let docker logs to flush...
        sleep 5
        if docker logs ${DOCKERNAME} 2>&1 | grep -Eq '^=+ End of start.sh'
        then
            break
        else
            echo "Docker image ${DOCKERNAME} not yet($i) ready !?"
        fi
    fi
done

# end of check-10-endStart.sh
