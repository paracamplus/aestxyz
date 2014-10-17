#! /bin/bash
# This script should not be used any longer!

exit 1

TIMEOUT=$1

for a in /tmp/*/author
do
    if [[ -f $a ]]
    then
        # seulement si vieux de plus de quelques heures...
        
        AUTHOR=$(cat $a)
        UUID=${a%/author}
        UUID=${UUID#/tmp/}
        log ${0##*/} $UUID

        # Try remove atomically
        OLDDIR=$(mktemp -d /tmp/z.XXXXXX)
        mv /tmp/$UUID /tmp/$OLDDIR
        rm -rf /tmp/$OLDDIR
        
        # See clean-old-exercises.sh comment
        deluser --quiet --remove-home $AUTHOR

    fi
done

# end of clean-unused-exercises.sh
