#
#                          Building aestxyz-vma
#
# Start a container only running an A server
# its configuration is in root.d/opt/a.paracamplus.com/
#
# Run this on the docker host:
#   Docker/a.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_y
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME a.paracamplus.com

WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80
RUN /root/RemoteScripts/setup.sh

#end.
