#! /bin/bash
# Start a docker server within the container while being built.

# NOTA: docker build --privileged is not allowed. So this script
# cannot run!

# if ! /etc/init.d/docker start
# then 
#     echo "Cannot start docker"
#     exit 45
# fi
# sleep 2

# # 
# if [ -d /opt/vmmd.paracamplus.com/Docker ]
# then
#     mv /opt/vmmd.paracamplus.com/Docker /root/
#     chmod u+x /root/Docker/*/*.sh
# fi

# # Prefetch vmms image:
# docker pull paracamplus/aestxyz_vmms

# See http://developerblog.redhat.com/2014/09/30/overview-storage-scalability-docker/

chmod a+x /usr/local/bin/wrapdocker

cat >>/etc/default/docker <<EOF
DOCKER_OPTS=" 
  --storage-opt dm.loopdatasize=5G 
  --storage-opt dm.loopmetadatasize=250M
"
EOF

# end of setup-65-docker.sh
