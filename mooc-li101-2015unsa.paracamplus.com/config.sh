#! /bin/bash
HOSTNAME=mooc-li101-2015unsa.paracamplus.com
HOSTPORT=64080
HOSTSSHPORT=64022
DOCKERNAME=mooc-li101-2015unsa
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# end of mooc-li101-2015unsa.paracamplus.com/config.sh
