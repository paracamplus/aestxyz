#! /bin/sh
# Inflate a compressed file into the current HOME directory.
# The compressed file is an exercise tar gzipped file.
# The compressed file will be removed afterthat.

FILE=$1

case "$FILE" in
    /*) 
        :
        ;;
    *)
        FILE=$( pwd )/$FILE
        ;;
esac

cd

case "$FILE" in
    *.tgz|*.tar.gz)
        trap "rm -f $FILE" 0
        exec tar xzf "$FILE"
        ;;
    *.tar)
        trap "rm -f $FILE" 0
        exec tar xf "$FILE"
        ;;
    *)
        echo "Don't know how to inflate $FILE!" 1>&2
        exit 101
        ;;
esac

# end of deploy-exercise.sh
