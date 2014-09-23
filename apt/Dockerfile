#
#                          Building aestxyz-apt
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... but no specific FW4EX code.
#
FROM debian:wheezy
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-aptitude-packages.sh

#end.
