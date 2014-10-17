#! /bin/bash
# Clean old exercises not yet removed.
# This script is ran every minute by root's crontab.

source $HOME/fw4exrootlib/commonLib.sh

if $USE_EXERCISE_CACHE
then 
    # should return immediately if the VM is currently marking in
    # order to not perturb the marking slave:
    if grep -q student < /etc/passwd
    then exit 0
    fi
else
    # when the cache is inactive, this script is not needed:
    exit 0
fi

# Log actions related to cache handling
VERBOSE=true

#

if $VERBOSE
then
    LOG=log
else
    LOG='echo >/dev/null '
fi

$LOG ${0##*/}

deployed_exercises() { (
   cd $EXERCISE_CACHE_DIR/ ; 
   ls -rtd ??????????????????????????????* 2>/dev/null
    )
}

disk_capacity() {
    df -B1000000 $EXERCISE_CACHE_DIR/ | \
        sed -rn -e '$s/^.* ([0-9]+)%.*$/\1/p'
# Attention: df sometimes outputs 3 lines instead of 2.
}

# How many exercises are deployed:
N=$( deployed_exercises | wc -l )
# The crontab runs every minute but the VM may accept concurrently
# some new jobs so take some margin:
TRUEN=$N
N=$(( $N + 10 ))
if [ $N -ge $AUTHORS_MAX_NUMBER ]
then 
    EXERCISE_CACHE_TIMEOUT=0
else
    EXERCISE_CACHE_TIMEOUT=$(( 
            ( $EXERCISE_CACHE_TIMEOUT * ( $AUTHORS_MAX_NUMBER - $N ) )
            / $AUTHORS_MAX_NUMBER ))
fi
$LOG ${0##*/} "$TRUEN exercises deployed, timeout=$EXERCISE_CACHE_TIMEOUT"

capacity=`disk_capacity`
EXERCISE_CACHE_TIMEOUT=$(( 
        ( $EXERCISE_CACHE_TIMEOUT * ( 100 - $capacity ) )
        / 100 ))
$LOG ${0##*/} "Used space=$capacity, timeout=$EXERCISE_CACHE_TIMEOUT"

# Examine oldest deployed exercises first:
NOW=$(date +%s)
for EXERCISEID in $( deployed_exercises )
do
    if [[ -f $EXERCISE_CACHE_DIR/$EXERCISEID/author ]]
    then 
        ACTIVE=false

        # As soon as one job is active wrt this exercise, no removal!
        for JOB in $( cd $EXERCISE_CACHE_DIR/$EXERCISEID ; 
                      ls *.job 2>/dev/null )
        do
            if [[ -f $EXERCISE_CACHE_DIR/$EXERCISEID/$JOB ]]
            then 
                ACTIVE=true
                $LOG ${0##*/} "job ${JOB%.job} still active"
                break
            fi
        done

        if $ACTIVE
        then break
        fi

        REMOVE=false
        LAST=$(date +%s -r $EXERCISE_CACHE_DIR/$EXERCISEID/author)
        if [ $(( $NOW - $LAST )) -gt $EXERCISE_CACHE_TIMEOUT ]
        then 
            $LOG ${0##*/} "Remove because $(( $NOW - $LAST )) > $EXERCISE_CACHE_TIMEOUT"
            REMOVE=true
        fi

        capacity=$( disk_capacity )
        if [ $capacity -ge $SPACE_THRESHOLD ]
        then 
            $LOG ${0##*/} "Remove since $capacity > $SPACE_THRESHOLD"
            REMOVE=true
        fi

        if $REMOVE
        then
            AUTHOR=$(< $EXERCISE_CACHE_DIR/$EXERCISEID/author)

            $LOG ${0##*/} Removing $EXERCISEID $AUTHOR

            # Try remove atomically
            OLDDIR=$(mktemp -d $EXERCISE_CACHE_DIR/z.XXXXXX)
            mv $EXERCISE_CACHE_DIR/$EXERCISEID $OLDDIR
            rm -rf $OLDDIR
            
            # Kill all processes owned by the author
            PIDS=$(ps -u $AUTHOR -o pid=)
            if [ "$PIDS" ]
            then kill -9 $PIDS
            fi
    
            # No! This comes in concurrence with available-student.sh
            # (and available-author.sh) which tries to lock /etc/passwd
            # concurrently as in:
            #useradd: cannot lock /etc/passwd; try again later.
            #adduser: `/usr/sbin/useradd -d /home/student01 -g student01 -s /bin/bash -u 1000 student01' returned error code 1. Exiting.
            #/usr/sbin/deluser --quiet --remove-home $AUTHOR
            rm -rf /home/$AUTHOR
            # The final deluser command will be done by the next call to
            # available-author.sh
        fi
    fi
done

# end of clean-old-exercises.sh
