#! /bin/bash
# Start an HTTP server in Perl to minimize memory usage and avoid Apache2.

export LANG=C
source /root/RemoteScripts/$HOSTNAME.sh

#UNIXNAME=${HOSTNAME//[.-]/_}
PERLMODULE=Paracamplus::FW4EX::${MODULE}
WWWUSER=web2user

if ! id $WWWUSER
then
    # FUTURE: 1300 should come from the Docker host
    adduser $WWWUSER --disabled-login --uid 1300 \
        --gecos 'Starman-Postgresql user' </dev/null
    adduser web2user www-data
fi

mkdir -p /opt/tmp/$HOSTNAME
PIDFILE=/opt/tmp/$HOSTNAME/server.pid
rm -f $PIDFILE 2>/dev/null

if [ -r /opt/$HOSTNAME/$HOSTNAME.yml ]
then
    export FW4EX_CONFIG_YML=/opt/$HOSTNAME/$HOSTNAME.yml
else
    echo "Missing configuration file /opt/$HOSTNAME/$HOSTNAME.yml"
    exit 51
fi

if [ -d /var/log/apache2 ]
then 
    logrotate --force /etc/logrotate.d/apache2 
else 
    mkdir -p /var/log/apache2
    chmod 750 /var/log/apache2
fi
chown -R ${WWWUSER}: /var/log/apache2

# Prepare cache for OpenId
mkdir -p /opt/$HOSTNAME/tmp/cache
chown ${WWWUSER}: /opt/$HOSTNAME/tmp/cache

# # (1) Development option
# cat > /opt/tmp/$HOSTNAME/server.pl <<EOF
# #!/usr/bin/env perl

# BEGIN {
#     \$ENV{CATALYST_SCRIPT_GEN} = 40;
# }

# use Catalyst::ScriptRunner;
# Catalyst::ScriptRunner->run("${PERLMODULE}", 'Server');

# 1;
# EOF

# chmod a+x /opt/tmp/$HOSTNAME/server.pl
# #export CATALYST_ENGINE='HTTP::Prefork'
# # will then use HTTP::Server::PSGI
# nohup /opt/tmp/$HOSTNAME/server.pl \
#     --port 80 --keepalive --background --pidfile $PIDFILE &

# (2) Production option
cat > /opt/tmp/$HOSTNAME/server.psgi <<EOF
#!/usr/bin/env perl

use strict;
use warnings;
use ${PERLMODULE};

my \$app = ${PERLMODULE}->apply_default_middlewares(
     ${PERLMODULE}->psgi_app);
\$app;
EOF

for file in /usr/local/share/perl/*/Starman/Server.pm 
do 
    sed -i -e '/log_level/s#4#DEBUG#' $file
done

cd /opt/tmp/$HOSTNAME
export STARMAN_DEBUG=1
/usr/local/bin/starman --daemonize --listen 0:80 \
    --user ${WWWUSER} --group ${WWWUSER} \
    --pid $PIDFILE --workers 5 \
    --error-log /var/log/apache2/error.log \
    --access-log /var/log/apache2/access.log \
    -M${PERLMODULE} \
    /opt/tmp/$HOSTNAME/server.psgi

# Monitor the starman server. From time to time, it becomes mad
# and consumes 100% of the CPU especially when the perl modules
# cannot be loaded (a syntax error for instance).
/root/RemoteScripts/starman.sh install-watch

# end of start-55-perlHttpServer.sh
