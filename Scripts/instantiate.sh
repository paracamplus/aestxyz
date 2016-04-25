#! /bin/bash

COURSE=$1
PORTPREFIX=${2:?missing PORTPREFIX}
SHORTNAME="${COURSE:-nothing}"
HOSTNAME="$SHORTNAME.paracamplus.com"
UPPERSHORTNAME="$( echo $SHORTNAME | tr a-z A-Z )"
MODULENAME="Paracamplus-FW4EX-$UPPERSHORTNAME"
MODULENAME=${MODULENAME//-/::}
SHORTBASENAME=${SHORTNAME%%_*}
UPPERSHORTBASENAME="$( echo $SHORTBASENAME | tr a-z A-Z )"

if [ -d $SHORTNAME ]
then 
    echo "WARNING: $SHORTNAME is already existing!"
fi

if ! host $HOSTNAME
then
    echo "ERROR: $HOSTNAME does not exist"
    exit 1
fi

echo "Configuring a Docker image to build:"

mkdir -p $SHORTNAME
if ! [ -f $SHORTNAME/Dockerfile ]
then cat > $SHORTNAME/Dockerfile <<EOF
#
#                          Building aestxyz-$SHORTNAME
#
# Start a container running a proxy dedicated to one course
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME $HOSTNAME

WORKDIR /root/
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
EOF
fi

(
    cd ../Servers/
    mkdir -p w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME
    cd w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME
    mkdir -p lib
    ( cd lib ; ln -sf ../../../../perllib/Paracamplus . )
    mkdir -p Templates
    (cd Templates ; ln -sf ../../../GenericApp/Templates Defaults )
)

if ! [ -d ../Servers/w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME ]
then
    echo "Missing ../Servers/w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME"
    exit 72
fi

mkdir -p $SHORTNAME/$HOSTNAME
if ! [ -f $SHORTNAME/$HOSTNAME/$HOSTNAME.sh ]
then cat > $SHORTNAME/$HOSTNAME/$HOSTNAME.sh <<EOF
#! /bin/bash
HOSTNAME=$HOSTNAME
APACHEUSER=www-data
RANK=409
SRCDIR=Servers/w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME
MODULE=$UPPERSHORTNAME
FRAGMENT='$SHORTNAME'
#DEBUG=true
# end of $HOSTNAME
EOF
fi
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-05-update.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-09-perllib.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-20-tar-Templates.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-40-path.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-50-keys.sh .)
#(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-80-cleanup.sh .)

mkdir -p $SHORTNAME/$HOSTNAME/root.d/usr/local/lib/site_perl/Paracamplus/FW4EX/$UPPERSHORTNAME

mkdir -p $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME
if ! [ -f $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml ]
then
    SRCDIR=Servers/w.$SHORTBASENAME/Paracamplus-FW4EX-$UPPERSHORTBASENAME
    if [ -f ../$SRCDIR/$HOSTNAME.yml ]
    then
        cp -p ../$SRCDIR/$HOSTNAME.yml \
            $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml
    else
        cat > $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml <<EOF
---
# Deployment of $HOSTNAME 
name: $MODULENAME
encoding: UTF-8
default_view: TT
abort_chain_on_error_fix: 1
using_frontend_proxy: 1

private_key_file: /opt/$HOSTNAME/fw4excookie.insecure.key
VERSION: 123

# to be continued.................................
EOF
    fi
fi

mkdir -p $SHORTNAME/RemoteScripts/
cp -fp remote-common/setup.sh $SHORTNAME/RemoteScripts/
cp -fp remote-common/start.sh $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-40-movePrivateKey.sh  $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-45-db.sh              $SHORTNAME/RemoteScripts/
#cp -fp remote-common/start-50-apache.sh          $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-55-perlHttpServer.sh  $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-60-sshd.sh            $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-65-dbtunnel.sh        $SHORTNAME/RemoteScripts/
cp -fp remote-common/dbtunnel.sh                 $SHORTNAME/RemoteScripts/
cp -fp remote-common/check-inner-availability.sh $SHORTNAME/RemoteScripts/
cp -fp remote-common/starman.sh                  $SHORTNAME/RemoteScripts/

# #############################################################
echo "Configuring the deployment of $HOSTNAME:"

mkdir -p $HOSTNAME
(cd $HOSTNAME ; ln -sf ../common/install.sh .)
if ! [ -f $HOSTNAME/config.sh ]
then cat > $HOSTNAME/config.sh <<EOF
#! /bin/bash
HOSTNAME=$HOSTNAME
HOSTPORT=${PORTPREFIX}80
HOSTSSHPORT=${PORTPREFIX}22
DOCKERNAME=${SHORTNAME}
DOCKERIMAGE=paracamplus/aestxyz_\${DOCKERNAME}
PROVIDE_SMTP=true
# end of $HOSTNAME/config.sh
EOF
fi
. $HOSTNAME/config.sh

(
    cd $HOSTNAME
    ln -sf ../common/check-05-varwwwstatic.sh .
    ln -sf ../common/check-10-endStart.sh .
    ln -sf ../common/check-outer-availability.sh .
)

mkdir -p $HOSTNAME/root.d/var/www/$HOSTNAME
if ! [ -f $HOSTNAME/root.d/var/www/$HOSTNAME/index.html ]
then cat > $HOSTNAME/root.d/var/www/$HOSTNAME/index.html <<EOF
Technical server for $SHORTNAME
EOF
fi

mkdir -p $HOSTNAME/root.d/etc/apache2/sites-available
if ! [ -f $HOSTNAME/root.d/etc/apache2/sites-available/$HOSTNAME ]
then cat > $HOSTNAME/root.d/etc/apache2/sites-available/$HOSTNAME <<EOF
<VirtualHost *:80> 
# This is the Apache configuration on the Docker host.
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  ${SHORTNAME}.paracamplus.com
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/${SHORTNAME}.paracamplus.com/
  AddDefaultCharset UTF-8

  AddType text/javascript .js
  AddType text/css        .css
  AddType application/xslt+xml .xsl
  AddType image/vnd.microsoft.icon .ico
  ExpiresActive On

        <Directory />
                AllowOverride None
                Options -Indexes 
                Order deny,allow
                Deny from all
        </Directory>

        <Directory /var/www/${SHORTNAME}.paracamplus.com/ >
                Options +FollowSymLinks
                Order allow,deny
                allow from all
        </Directory>

        <Directory /var/www/${SHORTNAME}.paracamplus.com/static/ >
                Options +FollowSymLinks
                Order allow,deny
                allow from all
                SetHandler default_handler
                FileETag none
                ExpiresActive On
                # expire images after 30 hours
                ExpiresByType image/gif A108000
                ExpiresByType image/png A108000
                ExpiresByType image/vnd.microsoft.icon A2592000
                # expires css and js after 30 hours
                ExpiresByType text/css        A108000
                ExpiresByType text/javascript A108000
        </Directory>

# ProxyPass must be sorted from most precise to less precise:
        ProxyPass /s/ http://s.paracamplus.com/s/
        ProxyPass /a/ http://a.paracamplus.com/
        ProxyPass /x/ http://x.paracamplus.com/
        ProxyPass /e/ http://e.paracamplus.com/
        ProxyPass /static/ !
        ProxyPass /favicon.ico !
        ProxyPass /   http://localhost:${HOSTPORT}/
# FUTURE limit the number of requests/second

# <Location> directives should be sorted from less to most precise:

        <Location /favicon.ico>
              Header append 'X-originator' 'Apache2 ${SHORTNAME}'
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/${SHORTNAME}.paracamplus.com/static/
        <Location /static/ >
              Header append 'X-originator' 'Apache2 ${UPPERSHORTNAME}'
              SetHandler default_handler
        </Location>

        Errorlog /var/log/apache2/${SHORTNAME}.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/${SHORTNAME}.paracamplus.com-access.log combined
        ServerSignature On

</VirtualHost>

EOF
fi

mkdir -p $HOSTNAME/root.d/etc/init.d
if ! [ -f $HOSTNAME/root.d/etc/init.d/qnc-docker.sh ]
then cat > $HOSTNAME/root.d/etc/init.d/qnc-docker.sh <<EOF
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
fi

# #############################################################
TESTHOSTNAME="$SHORTNAME.vld7net.fr"
echo "Configuring the test deployment on $TESTHOSTNAME"

mkdir -p $TESTHOSTNAME
(
    cd $TESTHOSTNAME 
    ln -sf ../common/install.sh .
    ln -sf ../common/check-outer-availability.sh .
    ln -sf ../common/check-10-endStart.sh .
    ln -sf ../../Servers/.ssh/dbuser_ecdsa .
    ln -sf ../../Servers/.ssh/fw4excookie.insecure.key .
    echo 'FILE dbuser_ecdsa' > keys.txt
)
if ! [ -f $TESTHOSTNAME/config.sh ]
then cat > $TESTHOSTNAME/config.sh <<EOF
#! /bin/bash
HOSTNAME=$TESTHOSTNAME
INNERHOSTNAME=$HOSTNAME
HOSTPORT=${PORTPREFIX}80
HOSTSSHPORT=${PORTPREFIX}22
DOCKERNAME=${SHORTNAME}
DOCKERIMAGE=paracamplus/aestxyz_\${DOCKERNAME}
# connect to local test database:
NEED_POSTGRESQL=true
PROVIDE_APACHE=false
PROVIDE_SMTP=false
# special for bijou:
REFRESH_DOCKER_IMAGES=false
SSHDIR=/tmp/Docker/${TESTHOSTNAME}/ssh.d
FW4EX_MASTER_KEY=/opt/common-paracamplus.com/fw4excookie.insecure.key
LOGDIR=/tmp/Docker/${TESTHOSTNAME}/log.d
SHARE_FW4EX_LOG=true
# end of $TESTHOSTNAME/config.sh
EOF
fi
. $TESTHOSTNAME/config.sh

mkdir -p $TESTHOSTNAME/root.d/opt/common-paracamplus.com
(
    cd $TESTHOSTNAME/root.d/opt/common-paracamplus.com/ 
    ln -sf ../../../../../Servers/.ssh/dbuser_ecdsa . 
    ln -sf ../../../../../Servers/.ssh/dbuser_ecdsa.pub . 
    ln -sf ../../../../../Servers/.ssh/fw4excookie.insecure.key .
)

if [ ! -f $TESTHOSTNAME/Imakefile ]
then
    cat > $TESTHOSTNAME/Imakefile <<EOF
# Start a local Docker with some host
# 
#  (cd $TESTHOSTNAME/ ; m run.local)
#
#if defined(SITE_is_bibou)
WAYDIR	=	/Users/Docker/${TESTHOSTNAME}
#else
WAYDIR	=	/tmp/Docker/${TESTHOSTNAME}
#endif

work : nothing 
clean ::
	rm -rf docker.* nohup.out root root.pub root_rsa root_rsa.pub \
		rootfs ssh.d ssh_host_ecdsa_key.pub

DOCKERNAME	=	${DOCKERNAME}
COURSE		=	${COURSE}
regenerate :
	make stop &
	cd .. ; m create.aestxyz_${DOCKERNAME} COURSE=${COURSE}

HOSTNAME	=	${TESTHOSTNAME}
run.local :
	[ -d \${WAYDIR} ] || rm -rf \${WAYDIR}
	-rm -rf \${WAYDIR}
	m update.Scripts
	cd \${WAYDIR} && ./install.sh
	echo "Connect with http://\$\$(cat \${WAYDIR}/docker.ip)/"

connect : update.Scripts
#	\${WAYDIR}/../Scripts/connect.sh ${TESTHOSTNAME}
	docker exec -it ${DOCKERNAME} bash

update.Scripts :
	mkdir -p \${WAYDIR}
	rsync -avuL ../Scripts        \${WAYDIR}/../
	rsync -avuL ../${HOSTNAME}/   \${WAYDIR}/

stop :
	docker stop ${COURSE}

INNERHOSTNAME	=	${INNERHOSTNAME}
RSYNC_FLAGS	=	--exclude='*~'
refresh.local :
#	echo 'chown -R 1299:1000 /usr/local/lib/site_perl/Paracamplus' | \
#		/tmp/Docker/Scripts/connect.sh ${TESTHOSTNAME}
	rsync -avu \${RSYNC_FLAGS} ../../perllib/Paracamplus \
	   \${WAYDIR}/rootfs/usr/local/lib/site_perl/
	rsync -avu \${RSYNC_FLAGS} ../../Servers/GenericApp/Templates/ \
	  \${WAYDIR}/rootfs/opt/${INNERHOSTNAME}/Templates/Default/
	rsync -avuL \${RSYNC_FLAGS} ../../$SRCDIR/root/ \
	  \${WAYDIR}/rootfs/var/www/${HOSTNAME}/
	{ echo "chown -R 1299: /usr/local/lib/site_perl/Paracamplus/" ;\
	  echo "/root/RemoteScripts/starman-stop.sh" ;\
	  echo "/root/RemoteScripts/start-55-perlHttpServer.sh" ;\
	  echo "tail -f /var/log/apache2/error.log" ;\
} | /tmp/Docker/Scripts/connect.sh ${TESTHOSTNAME}

# end of Makefile
EOF
fi

# #############################################################
# Finale
cat <<EOF

**************************************************************
Files to be edited for Docker:
   $SHORTNAME/$INNERHOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml
then
      m create.aestxyz_$SHORTNAME COURSE=$SHORTNAME

Deploy $INNERHOSTNAME with
      m deploy.$INNERHOSTNAME COURSE=$SHORTNAME

Test deployment on $TESTHOSTNAME:
      ( cd $TESTHOSTNAME ; m run.local )

EOF

# end of instantiate.sh
