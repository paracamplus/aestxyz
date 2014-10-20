#
#                          Building aestxyz-vmms1
#
# Prepare the basic part of a container only running a Marking Slave
# (some programming languages with specific installation)
#
FROM paracamplus/aestxyz_vmms0
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmms1.paracamplus.com

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/setup-22-languages.sh
# @bijou: 12 min

#end.
