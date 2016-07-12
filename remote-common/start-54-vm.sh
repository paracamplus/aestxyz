#! /bin/bash
# Change the base for requests if this container is run in a VM.

if [ -f /opt/$HOSTNAME/inVM ]
then
    base=/${HOSTNAME%%.paracamplus.com}/
    yml=/opt/$HOSTNAME/$HOSTNAME.yml
    echo "Adding base: $base to $yml"
    if ! grep -q "^base:" < $yml
    then
        echo "base: $base" >> $yml
    fi
fi

# end of start-54-vm.sh
