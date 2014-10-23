#! /bin/bash

docker images | \
sed -ne '/^<none> *<none>/s#<none> *<none> *##p' |\
while read id rest
do
    docker rmi $id
done
docker images

# end of remove-useless-images.sh
