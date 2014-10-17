#! /bin/bash

MODULES=${1:-/root/RemoteScripts/perl-modules.txt}

cd /root/
HOME=/root

# Assume cpan to be already configured.
#cpan . </dev/null

# Make CPAN configuration global:
if [ -f .cpan/CPAN/MyConfig.pm ]
then
    cp -p .cpan/CPAN/MyConfig.pm /etc/perl/CPAN/Config.pm
else
    echo "Cannot find .cpan/CPAN/MyConfig.pm" 1>&2
    exit 3
fi

sed -e 's/#.*$//' -e '/^\s*$/d' < $MODULES |\
while read m flags
do
    echo "===installing $m ($flags)... "
    cpan $flags $m </dev/null
    if ! perl -M$m -e 1 2>/dev/null
    then 
        echo UNINSTALLED $m 
        exit 1
    fi
done | tee /tmp/${0##*/}.log

# Check for anomalies:
sed -ne '/Result: FAIL/,+1p' < /tmp/${0##*/}.log |\
  grep -v 'Result: FAIL' > /tmp/bad.${0##*/}.log
if [ 1 -le `wc -l < /tmp/bad.${0##*/}.log` ]
then 
    # But don't display forced modules (we already know we forced them!)
    sed -e 's/#.*$//' -e '/^\s*$/d' < $MODULES | grep ' -f' |\
    while read m flags
    do
        sed -i -e "/${m//::/-}/d" /tmp/bad.${0##*/}.log
    done
    if [ 1 -le `wc -l < /tmp/bad.${0##*/}.log` ]
    then {
            echo "Problematic Perl modules:" 
            cat /tmp/bad.${0##*/}.log
            exit 2
         } 1>&2
    fi
fi 

/root/RemoteScripts/cleancpan.sh
rm -f /tmp/*${0##*/}.log

# end of install-perl-modules.sh
