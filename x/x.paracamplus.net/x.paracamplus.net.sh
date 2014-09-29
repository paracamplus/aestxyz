#! /bin/bash
HOSTNAME=x.paracamplus.net
APACHEUSER=www-data
RANK=405
SRCDIR=Servers/x/Paracamplus-FW4EX-X
MODULE=X
# We must request localhost with a Host=$HOSTNAME HTTP header since Docker
# force the container to have only one hostname.
#URL=http://$HOSTNAME/
FRAGMENT='XML server'
#DEBUG=true
# end of x.paracamplus.net.sh
