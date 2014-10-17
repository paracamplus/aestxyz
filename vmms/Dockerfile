#
#                          Building aestxyz-vmms
#
# Start a container only running a Marking Slave
#
# Run this on the docker host:
#   Docker/vmms.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_vmms0
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmms.paracamplus.com

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

EXPOSE 22
RUN /root/RemoteScripts/setup.sh

#end.
