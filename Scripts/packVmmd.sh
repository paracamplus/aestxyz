#! /bin/bash

CONTAINER=$1
IMAGE=$2

I=1

while true
do
    echo "Waiting ($I)"
    I=$(( $I+1 ))
    sleep 60
    if docker logs $CONTAINER | grep -q 'This is the end'
    then 
        break
    elif docker logs $CONTAINER | grep -q 'Could not connect to Docker daemon'
    then
        exit 49
    else
        docker logs $CONTAINER | tail -n4
    fi
done

echo "Committing image $IMAGE"
if docker commit $CONTAINER $IMAGE
then 
    docker images | head -n6
else
    if docker export $CONTAINER >/tmp/$CONTAINER.tar
    then
        wc -c /tmp/$CONTAINER.tar
        docker import - $IMAGE </tmp/$CONTAINER.tar
    fi
fi

# end of packVmmd.sh
