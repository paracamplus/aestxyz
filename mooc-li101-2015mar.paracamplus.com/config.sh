#! /bin/bash
HOSTNAME=mooc-li101-2015mar.paracamplus.com
HOSTPORT=63080
HOSTSSHPORT=63022
DOCKERNAME=mooc-li101-2015mar
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# end of mooc-li101-2015mar.paracamplus.com/config.sh
