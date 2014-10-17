#! /bin/sh
# Inflate a compressed file into the current HOME directory.
# The compressed file may be an exercise or a student's submission.
# The compressed file will be removed afterthat.

FILE=$1

case "$FILE" in
    /*) : ;;
    *)
        FILE=$( pwd )/$FILE
        ;;
esac

cd

case "$FILE" in
    *.tgz|*.tar.gz)
        trap "rm -f $FILE" 0
        tar xzf "$FILE"
        ;;
    *.tar)
        trap "rm -f $FILE" 0
        tar xf "$FILE"
        ;;
    *)
        echo "Don't know how to inflate $FILE!" 1>&2
        exit 101
        ;;
esac

# end of deploy-file.sh
