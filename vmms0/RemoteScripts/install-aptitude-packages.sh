#! /bin/bash
# Install all the debian modules specified in a file.

MODULES=${1:-/root/RemoteScripts/debian-modules.txt}

cd /root/
HOME=/root

apt-get update
apt-get -y install apt-utils
apt-get -y install aptitude
aptitude update
aptitude -y safe-upgrade

# NOTA: some packages want to use perl Term::ReadLine
cpan . </dev/null
cpan Term::ReadLine

sed -e 's/#.*$//' -e '/^\s*$/d' < $MODULES | \
while read m flags
do
    echo "===installing $m..."
    aptitude -q -y install $m
    aptitude clean
done | tee /tmp/${0##*/}.log

# Check that all packages are correctly installed:
if grep -q 'Couldn.t find package' < /tmp/${0##*/}.log
then 
    echo " * * * * * * Missing packages" 1>&2
    grep 'Couldn.t find package' < /tmp/${0##*/}.log 1>&2
    exit 1
fi

# Final cleanup
aptitude clean
aptitude purge mpt-status
rm -f /tmp/${0##*/}.log

# end of install-aptitude-packages.sh
