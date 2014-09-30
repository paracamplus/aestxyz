#! /bin/bash
# Restart docker container

### BEGIN INIT INFO
# Provides:          qncDockerA
# Required-Start:    $local_fs $remote_fs $network $named $time docker
# Required-Stop:     $local_fs $remote_fs $network $named $time docker
# Should-Start:      $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Restart Docker containers
# Description:       Restart Docker containers for ns353482.ovh.net
### END INIT INFO

# Install with            update-rc.d qnc-docker.sh defaults

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

HOSTNAME=y.paracamplus.com
DOCKERNAME=vmy

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
