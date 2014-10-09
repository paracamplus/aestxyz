#! /bin/bash
# setup*.sh and start*.sh scripts cannot be symbolically linked.
# Docker copies them as links not as files so update the shared scripts
# from Docker/remote-common/ inside RemoteScripts/

for g in ${0%/*}/../RemoteScripts/*.sh
do
    f=${g##*/}
    if [ -f ${0%/*}/../../remote-common/$f ]
    then
        cp -pf ${0%/*}/../../remote-common/$f $g
    fi
done

# end of prepare-05-update.sh
