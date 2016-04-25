#! /bin/bash
# Run on the docker host

if [ ! -n "$SCRIPTSDIR" ]
then
    echo "WARNING: Cannot update scripts (missing SCRIPTSDIR)"
    exit
fi

check () {
    local file=$1
    local original=$2
    if [ -f $original ]
    then
        if [ $file -ot $original ]
        then
            echo "Updating script $file"
            cp -p $original .
        fi
    fi
}

for file in *
do
    echo "Checking freshness of $file"
    case "$file" in
        config.sh)
            if cmp $file $SCRIPTSDIR/../$HOSTNAME/$file
            then :
            else
                echo "Configurations differ! Fix it with "
                echo " cp -p $SCRIPTSDIR/../$HOSTNAME/$file `pwd`/$file"
                exit 55
            fi
            ;;
        check-*.sh)
            check $file $SCRIPTSDIR/$file
            ;;
        install*.sh)
            check $file $SCRIPTSDIR/$file
            ;;
    esac
done

# end of install-00-update.sh
