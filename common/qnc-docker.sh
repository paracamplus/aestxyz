#! /bin/bash
# Restart docker container

### BEGIN INIT INFO
# Provides:          qncDockerXXX
# Required-Start:    $local_fs $remote_fs $network $named $time docker
# Required-Stop:     $local_fs $remote_fs $network $named $time docker
# Should-Start:      $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Restart Docker containers
# Description:       Restart Docker containers 
### END INIT INFO

# Install with            update-rc.d qnc-dockerXXX.sh defaults

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

HOSTNAME=XXX.paracamplus.com
DOCKERNAME=XXX

case "$1" in
    start) 
        /root/Docker/$HOSTNAME/install.sh 
        ;;
    stop)
        docker stop 
        ;;
    restart)
        $0 stop
        sleep 5
        $0 start
        ;;
    status)
        docker ps -a | grep $DOCKERNAME
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac        

# end of qnc-docker.sh
