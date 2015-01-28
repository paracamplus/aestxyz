#! /bin/bash
HOSTNAME=x.paracamplus.com
HOSTPORT=53080
HOSTSSHPORT=53022
DOCKERNAME=vmx
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# end of config.sh
