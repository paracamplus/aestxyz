#
#                          Building aestxyz-vmy
#
# Start a container only running a Y server
# its configuration is in root.d/opt/vmy.paracamplus.net/
#
# Run this on the docker host:
#   vmy.paracamplus.net/install.sh
#
FROM paracamplus/aestxyz_y
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80
RUN /root/RemoteScripts/setup.sh

#end.
