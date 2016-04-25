#! /bin/bash
HOSTNAME=li218.paracamplus.com
HOSTPORT=62980
HOSTSSHPORT=62922
DOCKERNAME=li218
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_${DOCKERNAME}
PROVIDE_SMTP=true
SHARE_FW4EX_LOG=false
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of li218.paracamplus.com/config.sh
