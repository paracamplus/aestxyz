#! /bin/bash
# Remove all finished containers but only if they are not tagged with
# a paracamplus/* tag.

docker ps -a | sed -ne '/paracamplus/b' -e '/Exited/s# .*$##p' |\
while read id
do
    docker rm $id
done

# end of remove-exited-containers.sh
