#! /bin/bash
HOSTNAME=e.paracamplus.net
APACHEUSER=www-data
RANK=402
SRCDIR=Servers/e/Paracamplus-FW4EX-E
MODULE=E
# We must request localhost with a Host=$HOSTNAME HTTP header since Docker
# force the container to have only one hostname.
#URL=http://$HOSTNAME/
FRAGMENT='Exercises server'
#DEBUG=true
# end of e.paracamplus.net.sh
