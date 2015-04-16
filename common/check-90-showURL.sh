#! /bin/bash

IP=`cat /tmp/Docker/$HOSTNAME/docker.ip`
cat <<EOF

  URL to access this Docker container ($HOSTNAME):
    http://$IP:$HOSTPORT/

  SSH to this Docker container with:
    /tmp/Docker/Scripts/connect.sh $HOSTNAME
    ssh -i /tmp/Docker/$HOSTNAME/root_rsa root@$IP 

  See logs with
    tail -F /tmp/Docker/$HOSTNAME/log.d/error.log

EOF

# end of check-90-showURL.sh
