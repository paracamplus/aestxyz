#! /bin/bash 
# Initialize the Docker container from within the container.
# Errors are signalled with a 2x code.

HOSTNAME=${HOSTNAME:-no.host.name}
source ${0%/*}/$HOSTNAME.sh

#hostname ${HOSTNAME%%.*}
#domainname ${HOSTNAME#*.}
CURRENTHOST=$(hostname)
#sed -i -e 's/$CURRENTHOST/$CURRENTHOST $HOSTNAME/' /etc/hosts

(
    echo "Configure extra modules for Apache"
    cd /etc/apache2/mods-enabled/ 
    ln -sf ../mods-available/expires.load .
    ln -sf ../mods-available/actions.* .
    ln -sf ../mods-available/cgi.* .
    ln -sf ../mods-available/headers.* .
    ln -sf ../mods-available/perl.* .
    ln -sf ../mods-available/proxy* .
    ln -sf ../mods-available/ssl.* .

    echo "Install $HOSTNAME Apache site"
    cd /etc/apache2/sites-enabled/
    ln -sf ../sites-available/$HOSTNAME $RANK-$HOSTNAME
    rm 000-default 2>/dev/null
)

( 
    cd /usr/local/lib/site_perl
    if [ -n "$SRCDIR" ]
    then 
        cd /usr/local/lib/site_perl/Paracamplus/FW4EX
        if ${DEBUG:-false}
        then
            echo "Debugging mode for $MODULE.pm"
            if [ -f ${MODULE}.pm ]
            then
                sed -i -e 's/^.*.-Debug.,/   "-Debug",/' ${MODULE}.pm
            fi
        else
            echo "Removing Debug mode from $MODULE.pm"
            if [ -f ${MODULE}.pm ]
            then
                sed -i -e '/^ *.*-Debug/s/^ /##No!/' ${MODULE}.pm
            fi
        fi
    fi
)

echo "Populate container"
if [ -f /root/RemoteScripts/root-$MODULE.tgz ]
then ( 
        cd /
        tar xvzf /root/RemoteScripts/root-$MODULE.tgz || exit 21
     )
fi

echo "Install Catalyst /opt/$HOSTNAME/Templates"
mkdir -p /opt/$HOSTNAME
if [ -f /root/RemoteScripts/$MODULE.tgz ]
then (
        cd /opt/$HOSTNAME
        tar xvzf /root/RemoteScripts/$MODULE.tgz Templates
     )
fi
echo "Install /var/www/$HOSTNAME"
mkdir -p /var/www/$HOSTNAME
if [ -f /root/RemoteScripts/$MODULE.tgz ]
then (
        cd /var/www/$HOSTNAME
        tar xvzf /root/RemoteScripts/$MODULE.tgz 
        rm -rf Templates
     )
fi

if [ 1 -le $( ls -1 ${0%/*}/setup-$MODULE-??.sh | wc -l ) ]
then 
    for f in ${0%/*}/setup-$MODULE-??.sh
    do
        echo "Sourcing $f"
        source $f || exit 22
    done
fi

if [ -n "$RANK" ]
then
    # This is necessary when removing a catalyst controller:
    echo "Removing automatically generated sub-classes code from /opt/tmp/"
    rm -rf /opt/tmp/$HOSTNAME 2>/dev/null
    echo "Checking Apache configuration"
    /usr/sbin/apache2ctl configtest || \
        tail -n20 /var/log/apache2/error.log
fi

# Apache should be restarted when the container will be ran.

# end of setup.sh
