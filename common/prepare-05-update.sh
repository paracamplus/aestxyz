#! /bin/bash
# setup*.sh and start*.sh scripts cannot be symbolically linked since
# Docker copies them as links not as files so update the shared scripts
# from Docker/remote-common/ inside RemoteScripts/

for g in ${0%/*}/../RemoteScripts/*.sh
do
    f=${g##*/}
    if [ -f ${0%/*}/../../remote-common/$f ]
    then
        if [ $f -ot ${0%/*}/../../remote-common/$f ]
        then
            rsync -avu ${0%/*}/../../remote-common/$f $g
        else
            echo "ATTENTION: $g is newer!"
            diff ${0%/*}/../../remote-common/$f $g
            exit 1
        fi
    fi
done

# end of prepare-05-update.sh
