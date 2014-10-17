#! /bin/bash
# Inflate a compressed job into the current HOME directory but only
# the ./content/ subdirectory (thus avoiding bringing fw4ex.xml in the
# student's directory). The compressed file will be removed afterthat.

# A job is a tgz with the following layout:
#         ./fw4ex.xml
#         ./content/*   the student's files
# instead of ./content/, one may also have
#         ./content.tgz

FILE=$1

case "$FILE" in
    /*) : ;;
    *)
        FILE=$( pwd )/$FILE
        ;;
esac

DIR=$( mktemp -d )

bringHome() {
    # Assume pwd = $DIR
    # NOTA: bringHome should be the last command of that script.
    if [[ -d content ]]
    then 
        exec rsync -au content/ $HOME/
    elif [[ -f content.tgz ]]
    then
        cd $HOME
        exec tar xzf $DIR/content.tgz
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

# end of deploy-job.sh
