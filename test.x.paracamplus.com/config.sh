#! /bin/bash
HOSTNAME=test.x.paracamplus.com
HOSTPORT=53980
HOSTSSHPORT=53922
DOCKERNAME=vmx
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
#PROVIDE_TUNNEL=5432
# connect to local test database:
PROVIDE_POSTGRESQL=true
PROVIDE_SMTP=true
# end of config.sh
