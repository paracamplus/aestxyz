#! /bin/bash
# Start an HTTP server in Perl to minimize memory usage and avoid Apache2.

export LANG=C

MODULE=Paracamplus::FW4EX::LI101::mooc_li101_2015mar_paracamplus_com

mkdir -p /opt/tmp/$HOSTNAME
PIDFILE=/opt/tmp/$HOSTNAME/server.pid
rm -f $PIDFILE 2>/dev/null

# # (1) Development option
# cat > /opt/tmp/$HOSTNAME/server.pl <<EOF
# #!/usr/bin/env perl

# BEGIN {
#     \$ENV{CATALYST_SCRIPT_GEN} = 40;
# }

# use Catalyst::ScriptRunner;
# Catalyst::ScriptRunner->run("${MODULE}", 'Server');

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
use ${MODULE};

my \$app = ${MODULE}->apply_default_middlewares(
     ${MODULE}->psgi_app);
\$app;
EOF

starman --daemonize --listen 0:80 \
    --user www-data --group www-data \
    --pid $PIDFILE --error-log /var/log/apache2/error.log \
    -MCatalyst -MDBIx::Class \
    /opt/tmp/$HOSTNAME/server.psgi

# end of start-55-perlHttpServer.sh
