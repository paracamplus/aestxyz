#! /bin/bash
# Display some information about the current container.
# This script is run from the directory where install.sh stays.

IP=`cat ./docker.ip`
SCRIPTSDIR=$(cd ../Scripts/ ; pwd)
cat <<EOF

  URL to access this Docker container ($HOSTNAME):
    http://$IP/
    http://127.0.0.1:$HOSTPORT/

  SSH to this Docker container with:
    $SCRIPTSDIR/connect.sh $HOSTNAME
    ssh -i `pwd`/root_rsa root@$IP 

  See installation log with
   docker logs $DOCKERNAME | less

  See logs with
    sudo tail -F `pwd`/rootfs/var/log/apache2/error.log

EOF

# end of check-90-showURL.sh
