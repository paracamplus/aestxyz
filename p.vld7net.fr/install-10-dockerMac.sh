#! /bin/bash
# Only required for boot2docker on MacOSX

work () {
    boot2docker ssh "mkdir -p /home/queinnec"
    boot2docker ssh "ln -sf /Users/queinnec /home/queinnec"

#    boot2docker ssh "sudo mkdir -p `pwd`"
#    tar czhf - -C ../ Scripts | \
#        boot2docker ssh sudo tar xzf - --overwrite -C `pwd`/../
#    tar czhf - . | boot2docker ssh sudo tar xzf - --overwrite -C `pwd`/
}

if which boot2docker >/dev/null
then
    # We suppose the Docker daemon to be run through boot2docker
    # This is the case for MacOSX.
    export USING_BOOT2DOCKER=true
    echo "Coping with boot2docker..."
    work
fi

# end of install-10-dockerMac.sh
