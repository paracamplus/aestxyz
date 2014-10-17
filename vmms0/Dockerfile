#
#                          Building aestxyz-vmms0
#
# Prepare the basic part of a container only running a Marking Slave
#
# Run this on the docker host:
#   Docker/vmms.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmms.paracamplus.com

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-aptitude-packages.sh /root/RemoteScripts/debian-modules-ms.txt
# @bijou: 24 min

RUN /root/RemoteScripts/install-perl-modules.sh /root/RemoteScripts/perl-modules-ms.txt
# @bijou: 9 min

RUN /root/RemoteScripts/setup-22-languages.sh

#end.
