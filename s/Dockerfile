#
#                          Building aestxyz-s
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... but no specific FW4EX code.
#
FROM paracamplus/aestxyz_e
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true
ENV HOSTNAME s.paracamplus.net

WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80
RUN /root/RemoteScripts/setup.sh

#end.
