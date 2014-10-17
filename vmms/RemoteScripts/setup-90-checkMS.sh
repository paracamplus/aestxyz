#! /bin/bash
# Runs as root within the container.
# Check that the main language utilities are present in the MS.

for program in gcc make python2 python3 ocaml \
    bash ruby octave mono gnat lua \
    bigloo mzscheme java
do
    echo "Is $program available?"
    if ! which $program
    then 
        echo Missing $program 1>&2
        exit 21
    fi
done

/root/RemoteScripts/cleanup.sh

# end of setup-90-checkMS.sh
