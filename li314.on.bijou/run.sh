#! /bin/bash

cp -f ${0%/*}/li314.vld7net.fr /etc/apache2/sites-enabled/301-li314.vld7net.fr

mkdir -p /var/www/li314.vld7net.fr/
PARACAMPLUSDIR=/home/queinnec/Paracamplus/ExerciseFrameWork
SERVERDIR=$PARACAMPLUSDIR/Servers/w.li314/Paracamplus-FW4EX-LI314/root
( cd $SERVERDIR/
  rsync -avuL index.html static /var/www/li314.vld7net.fr/
)

${0%/*}/install.sh

# end of run.sh
