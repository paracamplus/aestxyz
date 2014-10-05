#! /bin/bash
# Restart docker container

### BEGIN INIT INFO
# Provides:          qncDockerLI314
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

HOSTNAME=li314.paracamplus.com
DOCKERNAME=li314

case "li314" in
    start) 
        /root/Docker/li314.paracamplus.com/install.sh 
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
