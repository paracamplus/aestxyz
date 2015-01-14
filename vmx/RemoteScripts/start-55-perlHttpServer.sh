#! /bin/bash
# Start an HTTP server in Perl to minimize memory usage and avoid Apache2.

export LANG=C
source /root/RemoteScripts/$HOSTNAME.sh

UNIXNAME=${HOSTNAME//[.-]/_}
PERLMODULE=Paracamplus::FW4EX::${MODULE}::$UNIXNAME

mkdir -p /opt/tmp/$HOSTNAME
PIDFILE=/opt/tmp/$HOSTNAME/server.pid
rm -f $PIDFILE 2>/dev/null

if [ -d /var/log/apache2 ]
then 
    logrotate --force /etc/logrotate.d/apache2 
else 
    mkdir -p /var/log/apache2
    chmod 750 /var/log/apache2
    chown root:adm /var/log/apache2
fi

# Prepare cache for OpenId
mkdir -p /opt/$HOSTNAME/tmp/cache
chown www-data: /opt/$HOSTNAME/tmp/cache

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

starman --daemonize --listen 0:80 \
    --user www-data --group www-data \
    --pid $PIDFILE --error-log /var/log/apache2/error.log \
    -MCatalyst -MDBIx::Class \
    /opt/tmp/$HOSTNAME/server.psgi

# end of start-55-perlHttpServer.sh
