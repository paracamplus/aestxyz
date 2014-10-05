#! /bin/bash

SHORTNAME="${1:-nothing}"
HOSTNAME="$SHORTNAME.paracamplus.com"
UPPERSHORTNAME="$( echo $SHORTNAME | tr a-z A-Z )"
MODULENAME="Paracamplus-FW4EX-$UPPERSHORTNAME"
MODULENAME=${MODULENAME//-/::}

echo "Configuring a Docker image to build:"

mkdir -p $SHORTNAME
cat > $SHORTNAME/Dockerfile <<EOF
#
#                          Building aestxyz-$SHORTNAME
#
# Start a container running a proxy dedicated to one course
#
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME $HOSTNAME
WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts
EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh
#end.
EOF

mkdir -p $SHORTNAME/$HOSTNAME
cat > $SHORTNAME/$HOSTNAME/$HOSTNAME.sh <<EOF
#! /bin/bash
HOSTNAME=$HOSTNAME
APACHEUSER=www-data
RANK=409
SRCDIR=Servers/w.$SHORTNAME/Paracamplus-FW4EX-$UPPERSHORTNAME
MODULE=$UPPERSHORTNAME
FRAGMENT='$SHORTNAME'
#DEBUG=true
# end of $HOSTNAME
EOF
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare.sh .)
#(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-20*.sh .)

mkdir -p $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME
cat > $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml <<EOF
---
# Deployment of $HOSTNAME 
name: $MODULENAME
encoding: UTF-8
default_view: TT
parse_on_demand: 1
abort_chain_on_error_fix: 1
using_frontend_proxy: 1

private_key_file: /opt/$HOSTNAME/fw4excookie.insecure.key

# to be continued.................................
EOF

mkdir -p $SHORTNAME/RemoteScripts/
cp -p remote-common/setup.sh $SHORTNAME/RemoteScripts/
cp -p remote-common/start.sh $SHORTNAME/RemoteScripts/
cp -p remote-common/start-40-movePrivateKey.sh  $SHORTNAME/RemoteScripts/
cp -p remote-common/start-50-apache.sh          $SHORTNAME/RemoteScripts/
cp -p remote-common/start-60-sshd.sh            $SHORTNAME/RemoteScripts/
cp -p remote-common/start-65-dbtunnel.sh        $SHORTNAME/RemoteScripts/
cp -p remote-common/check-inner-availability.sh $SHORTNAME/RemoteScripts/

echo "Configuring the deployment of $HOSTNAME:"

mkdir -p $HOSTNAME
(cd $HOSTNAME ; ln -sf ../common/install.sh .)
cat > $HOSTNAME/config.sh <<EOF
#! /bin/bash
HOSTNAME=$HOSTNAME
HOSTPORT=X54080
HOSTSSHPORT=X54022
DOCKERNAME=${SHORTNAME}
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# end of $HOSTNAME/config.sh
EOF

mkdir -p $HOSTNAME/root.d/etc/apache2/sites-available
cat > $HOSTNAME/root.d/etc/apache2/sites-available/$HOSTNAME <<EOF

EOF

mkdir -p $HOSTNAME/root.d/etc/init.d
cat > $HOSTNAME/root.d/etc/init.d/qnc-docker.sh <<EOF
#! /bin/bash
# Restart docker container

### BEGIN INIT INFO
# Provides:          qncDocker$UPPERSHORTNAME
# Required-Start:    \$local_fs \$remote_fs \$network \$named \$time docker
# Required-Stop:     \$local_fs \$remote_fs \$network \$named \$time docker
# Should-Start:      \$syslog
# Should-Stop:       \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Restart Docker containers
# Description:       Restart Docker containers 
### END INIT INFO

# Install with            update-rc.d qnc-docker.sh defaults

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

HOSTNAME=$HOSTNAME
DOCKERNAME=$SHORTNAME

case "$1" in
    start) 
        /root/Docker/$HOSTNAME/install.sh 
        ;;
    stop)
        docker stop $DOCKERNAME
        ;;
    restart)
        $0 stop
        sleep 5
        $0 start
        ;;
    status)
        docker ps -a
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac        

# end of qnc-docker.sh
EOF

# Finale
cat <<EOF

**************************************************************
Files to be edited for Docker:
   $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml
then      m create.aestxyz_$SHORTNAME COURSE=$SHORTNAME

Files to be edited to deply $HOSTNAME:
   $HOSTNAME/config.sh
   $HOSTNAME/root.d/etc/apache2/sites-available/$HOSTNAME
then    m deploy.$HOSTNAME COURSE=$SHORTNAME
   
EOF

# end of instantiate.sh
