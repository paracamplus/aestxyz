#
#                          Building aestxyz-vme
#
# Start a container only running an E server
# its configuration is in root.d/opt/e.paracamplus.com/
#
# Run this on the docker host:
#   Docker/e.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_y
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME e.paracamplus.com

WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80
RUN /root/RemoteScripts/setup.sh

#end.
