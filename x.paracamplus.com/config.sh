#! /bin/bash
HOSTNAME=x.paracamplus.com
HOSTPORT=53080
HOSTSSHPORT=53022
DOCKERNAME=vmx
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of config.sh
