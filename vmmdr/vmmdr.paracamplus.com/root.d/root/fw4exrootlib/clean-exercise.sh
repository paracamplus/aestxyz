#! /bin/bash
# Clean data belonging to an exercise.
# EXERCISEID qualifies the exercise.
# JOBID qualifies the job.

source $HOME/fw4exrootlib/commonLib.sh

EXERCISEID=$1
JOBID=$2
AUTHOR=$3

log ${0##*/} $EXERCISEID for $JOBID

if $USE_EXERCISE_CACHE
then
    # refresh the exercise since it is finishing the marking of a job:
    touch $EXERCISE_CACHE_DIR/$EXERCISEID/author
    # Don't cleanup immediately
    rm -f $EXERCISE_CACHE_DIR/$EXERCISEID/$JOBID.job
    rm -f $EXERCISE_CACHE_DIR/$EXERCISEID/$JOBID.tgz
    log ${0##*/} $EXERCISEID $JOBID "Differed clean-up!"

    # FUTURE Should be done only once!!!!!
    CRONTAB=$( mktemp /tmp/crontabXXXXXXX )
    trap "rm -f $CRONTAB" 0
    crontab -l > $CRONTAB 2>/dev/null
    if grep -q clean-old-exercises.sh < $CRONTAB
    then :
    else
        echo '* * * * * /root/fw4exrootlib/clean-old-exercises.sh' >> $CRONTAB
        crontab $CRONTAB
    fi

else
    # Clean up the exercise entirely!
    log ${0##*/} $EXERCISEID $JOBID "Cleaning up $AUTHOR..."
    # Try remove atomically
    OLDDIR=$(mktemp -d $EXERCISE_CACHE_DIR/z.XXXXXX)
    mv $EXERCISE_CACHE_DIR/$EXERCISEID $OLDDIR
    rm -rf $OLDDIR

    # Kill all processes owned by the author
    PIDS=$(ps -u $AUTHOR -o pid=)
    if [ "$PIDS" ]
    then kill -9 $PIDS
    fi
    
    deluser --quiet --remove-home $AUTHOR
    log ${0##*/} $EXERCISEID $JOBID "Clean-up done!"
fi

# end of clean-exercise.sh
