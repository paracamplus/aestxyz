#! /bin/bash
# Push a container with its latest and most accurate label
# Example:
#    Scripts/dockerpush.sh www.paracamplus.com:5000/paracamplus/aestxyz_vma

DOCKERIMAGE=$1

# remove the final tag if any:
DOCKERIMAGE=${DOCKERIMAGE%:*}

# find the most accurate label
TMPF=$( mktemp )
docker images | grep -E "^${DOCKERIMAGE} " > $TMPF
LATEST=$( sed -rne '/latest/s#[^ ]*  *latest *([^ ]*) .*$#\1#p' < $TMPF )
REALTAG=$( sed -rne '/latest/d' -e /$LATEST/'s#^[^ ]*  *([^ \n]*) .*$#\1#p' < $TMPF )

if [ -n "$REALTAG" ]
then
    docker push ${DOCKERIMAGE}:${REALTAG}
fi
docker push ${DOCKERIMAGE}:latest

# end of dockerpush.sh
