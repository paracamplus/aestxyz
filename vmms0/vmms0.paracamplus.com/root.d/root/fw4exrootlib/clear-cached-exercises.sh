#! /bin/bash
# Imperatively clean the cache of deployed exercices.
# WARNING: Currently, does not take care of potentially running jobs
# using these deployed exercises.

source $HOME/fw4exrootlib/commonLib.sh

log ${0##*/}

for a in $EXERCISE_CACHE_DIR/*/author
do
    if [[ -f $a ]]
    then
        
        AUTHOR=$(cat $a)
        UUID=${a%/author}
        UUID=${UUID#$EXERCISE_CACHE_DIR/}
        log ${0##*/} $UUID

        # Try remove atomically
        OLDDIR=$(mktemp -d $EXERCISE_CACHE_DIR/z.XXXXXX)
        mv $EXERCISE_CACHE_DIR/$UUID $OLDDIR
        rm -rf $OLDDIR
        
        # Kill all processes owned by the author
        PIDS=$(ps -u $AUTHOR -o pid=)
        if [ "$PIDS" ]
        then kill -9 $PIDS
        fi
        
        # See comment in clean-old-exercises.sh
        #deluser --quiet --remove-home $AUTHOR
        rm -rf /home/$AUTHOR
    fi
done

# end of clear-cached-exercises.sh
