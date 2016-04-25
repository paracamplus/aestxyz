#! /bin/bash
HOSTNAME=li314.paracamplus.com
HOSTPORT=55080
HOSTSSHPORT=55022
DOCKERNAME=li314
DOCKERIMAGE=www.paracamplus.com:5000/paracamplus/aestxyz_li314
PROVIDE_SMTP=true
# Use direct socket to connect to the database (the Docker container
# is on the same machine as the database):
NEED_POSTGRESQL=true
# to update deployment scripts on the Docker host:
SCRIPTSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/common
# end of li314.paracamplus.com/config.sh
