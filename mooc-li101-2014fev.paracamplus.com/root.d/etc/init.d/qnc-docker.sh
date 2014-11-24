#! /bin/bash
# Restart docker container

### BEGIN INIT INFO
# Provides:          qncDockerMooc_li101_2014fev
# Required-Start:    $local_fs $remote_fs $network $named $time docker
# Required-Stop:     $local_fs $remote_fs $network $named $time docker
# Should-Start:      $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Restart Docker containers
# Description:       Restart Docker containers 
### END INIT INFO

# Install with            update-rc.d qnc-docker.sh defaults

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

HOSTNAME=mooc-li101-2014fev.paracamplus.com
DOCKERNAME=mooc-li101-2014fev

case "$1" in
    start) 
        /root/Docker/$HOSTNAME/install.sh 
        ;;
    stop)
        docker stop 
        ;;
    restart)
        ./Scripts/instantiate.sh stop
        sleep 5
        ./Scripts/instantiate.sh start
        ;;
    status)
        docker ps -a
        ;;
    *)
        echo "Usage: ./Scripts/instantiate.sh {start|stop|restart|status}"
        exit 1
        ;;
esac        

# end of qnc-docker.sh
