#! /bin/bash
HOSTNAME=mooc-li101-2015unsa.paracamplus.com
HOSTPORT=64080
HOSTSSHPORT=64022
DOCKERNAME=mooc-li101-2015unsa
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of mooc-li101-2015unsa.paracamplus.com/config.sh
