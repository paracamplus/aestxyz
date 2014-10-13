#
#                          Building aestxyz-oldapt
#
# This is a variant of aestxyz-apt with Debian6 not Debian7.
#
FROM debian:squeeze
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts                /root/RemoteScripts

RUN /root/RemoteScripts/install-aptitude-packages.sh

#end.
