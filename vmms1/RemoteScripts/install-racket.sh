#! /bin/bash
# Runs as root in the Marking Slave container. Install Racket

RACKET=$(ls -t1 /opt/TGZ/racket* | head -n1)

if which mzscheme
then
    echo "Racket already installed"
    exit
fi

case "$RACKET" in
    *.sh)
        # Unix style installation (in /usr) and default options:
        { echo yes ; echo ; echo ; } | bash -f "$RACKET"
        ;;
    *)
        echo "Unknown type of archive ($RACKET)"
        exit 26
        ;;
esac

if which mzscheme
then
    rm -f $RACKET
    rm -rf /usr/share/racket/doc
else
    echo "Racket does not seem to work!"
    exit 22
fi

# end of setup-37-racket.sh
