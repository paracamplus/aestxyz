#
#                          Building aestxyz-vmms0
#
# Prepare the basic part of a container only running a Marking Slave
# (debian packages and perl modules)
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmms0.paracamplus.com

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-aptitude-packages.sh /root/RemoteScripts/debian-modules-ms.txt
# @bijou: 24 min

RUN /root/RemoteScripts/install-perl-modules.sh /root/RemoteScripts/perl-modules-ms.txt
# @bijou: 9 min

# @bijou (2015sep): 25min

#end.
