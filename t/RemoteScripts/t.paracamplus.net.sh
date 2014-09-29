#! /bin/bash
HOSTNAME=t.paracamplus.net
APACHEUSER=www-data
RANK=404
SRCDIR=Servers/t/Paracamplus-FW4EX-T
MODULE=T
# We must request localhost with a Host=$HOSTNAME HTTP header since Docker
# force the container to have only one hostname.
#URL=http://$HOSTNAME/
FRAGMENT='Le coin des auteurs'
#DEBUG=true
# end of t.paracamplus.net.sh
