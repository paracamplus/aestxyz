#! /bin/bash

SHORTNAME="${1:-nothing}"
HOSTNAME="$SHORTNAME.paracamplus.com"
UPPERSHORTNAME="$( echo $SHORTNAME | tr a-z A-Z )"
MODULENAME="Paracamplus-FW4EX-$UPPERSHORTNAME"
MODULENAME=${MODULENAME//-/::}

if [ -d $SHORTNAME ]
then 
    echo "WARNING: $SHORTNAME is already existing!"
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
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME $HOSTNAME
WORKDIR /root/
ADD perllib.tgz                  /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts
EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh
#end.
EOF
fi

if ! [ -d ../Servers/w.$SHORTNAME/Paracamplus-FW4EX-$UPPERSHORTNAME ]
then
    echo "Missing ../Servers/w.$SHORTNAME/Paracamplus-FW4EX-$UPPERSHORTNAME"
    exit 72
fi

mkdir -p $SHORTNAME/$HOSTNAME
if ! [ -f $SHORTNAME/$HOSTNAME/$HOSTNAME.sh ]
then cat > $SHORTNAME/$HOSTNAME/$HOSTNAME.sh <<EOF
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
fi
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-05-update.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-09-perllib.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-20-tar-Templates.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-40-path.sh .)
(cd $SHORTNAME/$HOSTNAME ; ln -sf ../../common/prepare-80-cleanup.sh .)

mkdir -p $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME
if ! [ -f $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml ]
then cat > $SHORTNAME/$HOSTNAME/root.d/opt/$HOSTNAME/$HOSTNAME.yml <<EOF
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
fi

mkdir -p $SHORTNAME/RemoteScripts/
cp -fp remote-common/setup.sh $SHORTNAME/RemoteScripts/
cp -fp remote-common/start.sh $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-40-movePrivateKey.sh  $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-50-apache.sh          $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-60-sshd.sh            $SHORTNAME/RemoteScripts/
cp -fp remote-common/start-65-dbtunnel.sh        $SHORTNAME/RemoteScripts/
cp -fp remote-common/check-inner-availability.sh $SHORTNAME/RemoteScripts/

echo "Configuring the deployment of $HOSTNAME:"

mkdir -p $HOSTNAME
(cd $HOSTNAME ; ln -sf ../common/install.sh .)
if ! [ -f $HOSTNAME/config.sh ]
then cat > $HOSTNAME/config.sh <<EOF
#! /bin/bash
HOSTNAME=$HOSTNAME
HOSTPORT=X54080
HOSTSSHPORT=X54022
DOCKERNAME=${SHORTNAME}
DOCKERIMAGE=paracamplus/aestxyz_${DOCKERNAME}
# end of $HOSTNAME/config.sh
EOF
fi

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
# Check syntax with /usr/sbin/apache2ctl -t

  ServerName  li314.paracamplus.com
              # temporary:
              ServerAlias li314.fw4ex.org
  ServerAdmin fw4exmaster@paracamplus.com
  DocumentRoot /var/www/li314.paracamplus.com/
  AddDefaultCharset UTF-8

  AddType text/javascript .js
  AddType text/css        .css
  AddType application/xslt+xml .xsl
  ExpiresActive On

        <Directory />
                Options FollowSymLinks
                AllowOverride None
                Options -Indexes 
                Order deny,allow
                Deny from all
        </Directory>

        <Directory /var/www/li314.paracamplus.com/ >
                Order allow,deny
                allow from all
        </Directory>

# <Location> directives should be sorted from less to most precise:

        <Location / >
              Order allow,deny
              allow from all
# FUTURE limit the number of requests/second
              # Relay to the Docker container
              ProxyPass        http://localhost:X54080/
              ProxyPassReverse http://localhost:X54080/
        </Location>

        <Location /favicon.ico>
              SetHandler default_handler
              ExpiresDefault A2592000
        </Location>

        Alias /static/ /var/www/li314.paracamplus.com/static/
        <Location /static/ >
                SetHandler default_handler
                FileETag none
                ExpiresActive On
                # expire images after 30 hours
                ExpiresByType image/gif A108000
                ExpiresByType image/png A108000
                # expires css and js after 30 hours
                ExpiresByType text/css        A108000
                ExpiresByType text/javascript A108000
        </Location>

        Errorlog /var/log/apache2/li314.paracamplus.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/li314.paracamplus.com-access.log combined
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
