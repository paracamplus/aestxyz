#! /bin/bash
# Try to install cpan modules as they were for Debian6.
# They are all packed in RemoteScripts/root-A.tgz
# There is also .cpan/Bundle/Snapshot_2014_10_13_00.pm

MODULES=${1:-/root/RemoteScripts/perl-modules.txt}

cd /root/
HOME=/root

# Expand all kept perl modules:
MODULE=A
if [ -f /root/RemoteScripts/root-$MODULE.tgz ]
then ( 
        echo "Populate container"
        cd /
        tar xzf /root/RemoteScripts/root-$MODULE.tgz || exit 21
        rm -f /root/RemoteScripts/root-$MODULE.tgz
     )
fi

# Assume cpan to be already configured.

# Attention MODULES is the list of perl modules for debian 7. We
# ignore those that were not present in the snapshot.

sed -e 's/#.*$//' -e '/^\s*$/d' < $MODULES |\
while read m flags
do
    echo "===Checking $m... "
    if grep -q $m < /root/RemoteScripts/.cpan/Bundle/Snapshot_2014_10_13_00.pm
    then
        if perl -M$m -e 1 2>/dev/null
        then 
            echo "$m is installed."
        else
            echo "Problem with $m"
            exit 1
        fi
    else
        echo "Ignore $m"
    fi
done | tee /tmp/${0##*/}.log

/root/RemoteScripts/cleancpan.sh

rm -f /tmp/*${0##*/}.log

# end of install-oldperl-modules.sh
