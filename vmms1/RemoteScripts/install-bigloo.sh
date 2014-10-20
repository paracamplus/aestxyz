#! /bin/bash
# Runs as root in the Marking Slave container. Install bigloo

BIGLOOTGZ=$(ls -t1 /opt/TGZ/bigloo* | head -n1)

if which bigloo
then 
    echo "Bigloo already installed"
    exit
fi

case "$BIGLOOTGZ" in
    *.tar.gz)
        cd /tmp/
        tar xzf $BIGLOOTGZ
        cd bigloo*/
        ./configure && make && make test
        make install
        ;;
    *)
        echo "Unknown type of archive ($BIGLOOTGZ)"
        exit 27
        ;;
esac

# RemoteScripts/setup-90-checkMS.sh will check that bigloo runs in the MS.

# end of setup-35-bigloo.sh
