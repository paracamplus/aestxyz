#! /bin/bash
# Deploy exercise means inflate the exercise.tgz into author's HOME.
# This is the part ran by root, another script (deploy-exercise) runs 
# as author to finish the work.

source $HOME/fw4exrootlib/commonLib.sh

AUTHOR=$1
EXERCISEID=$2
EXERCISETGZ=$3

log ${0##*/} $AUTHOR $EXERCISEID

if [[ -r $EXERCISETGZ ]]
then 
    # Make it writable so it may be rewritten:
    chmod 644 $EXERCISETGZ
else
    echo "Missing tgz $EXERCISETGZ!" 1>&2
    exit 110
fi

EXERCISE_SCRIPT=$EXERCISE_CACHE_DIR/$EXERCISEID/exercise.sh

if [[ -f $EXERCISE_SCRIPT.OK ]]
then
    log ${0##*/} $AUTHOR $EXERCISEID "already deployed!"
    exit 0

else {
        chmod 644 $EXERCISETGZ
        echo /home/fw4ex/fw4exlib/deploy-exercise.sh $EXERCISETGZ
    } | su - $AUTHOR 2>>$EXERCISE_CACHE_DIR/$EXERCISEID/err.txt
    if [[ ! -f $(echo pwd | su - $AUTHOR)/fw4ex.xml ]]
    then 
        log ${0##*/} $AUTHOR $EXERCISEID "not inflated!?" \
            "file: $EXERCISETGZ" \
            $(cat $EXERCISE_CACHE_DIR/$EXERCISEID/err.txt)
        exit 110
    fi
fi

# end of deployExercise.sh
