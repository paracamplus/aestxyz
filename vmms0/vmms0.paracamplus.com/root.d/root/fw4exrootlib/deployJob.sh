#! /bin/bash
# Inflate a compressed job into a student's HOME directory but only
# the ./content/ subdirectory (thus avoiding bringing fw4ex.xml in the
# student's directory). The compressed file will be removed afterthat.

# A job is a tgz with the following layout:
#         ./fw4ex.xml
#         ./content/*   the student's files
# instead of ./content/, one may also have
#         ./content.tgz

# This script is ran by root but inflated files should belong to student.

source $HOME/fw4exrootlib/commonLib.sh

STUDENT=$1
FILE=$2

case "$FILE" in
    /*) : ;;
    *)
        FILE=$( pwd )/$FILE
        ;;
esac

log ${0##*/} $STUDENT $FILE

if [[ -f $FILE ]]
then :
else
    echo "No job file $FILE to deploy!" 1>&2
    exit 104
fi

SHOME=/home/$STUDENT
if [[ -d $SHOME ]]
then :
else
    echo "No such user $STUDENT!" 1>&2
    exit 105
fi

DIR=$( mktemp -d )

bringHome() {
    # Assume pwd = $DIR
    # NOTA: bringHome should be the last command of that script.
    if [[ -d content ]]
    then 
        rsync -au content/ $SHOME/
        chown -R ${STUDENT}: $SHOME/
        log ${0##*/} $STUDENT $FILE " deployed!"
        ls -Rl $SHOME | logdebug ${0##*/} $STUDENT $FILE ls -Rl $SHOME/
    elif [[ -f content.tgz ]]
    then
        cd $SHOME
        tar xzf $DIR/content.tgz
        chown -R ${STUDENT}: $SHOME/
        log ${0##*/} $STUDENT $FILE " inflated!"
        ls -Rl $SHOME | logdebug ${0##*/} $STUDENT $FILE ls -Rl $SHOME/
    else
        echo "Cannot deploy job from $FILE!" 1>&2
        exit 102
    fi
}

case "$FILE" in
    *.tgz|*.tar.gz)
        trap "rm -rf $FILE $DIR" 0
        cd $DIR/
        tar xzf $FILE
        bringHome
        ;;
    *.tar)
        trap "rm -rf $FILE $DIR" 0
        cd $DIR/
        tar xf $FILE
        bringHome
        ;;
    *)
        echo "Don't know how to inflate $FILE!" 1>&2
        exit 101
        ;;
esac

# end of deployJob.sh
