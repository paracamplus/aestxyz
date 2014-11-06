#! /bin/bash
# This script analyses the output of make create.aestxyz_vmmd and
# determine when to commit the final image.

CONTAINER=$1
IMAGE=$2

I=1

while true
do
    echo "Waiting ($I)"
    I=$(( $I+1 ))
    sleep 60
    if docker logs $CONTAINER 2>&1 | grep -q 'This is the end'
    then 
        break
    elif docker logs $CONTAINER 2>&1 | grep -q 'exit 4'
    then
        docker logs $CONTAINER 2>&1 | tail -n20
        exit 49
    else
        docker logs $CONTAINER 2>&1 | tail -n4
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
