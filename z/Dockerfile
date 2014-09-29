#
#                          Building aestxyz-z
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... but no specific FW4EX code.
#
FROM paracamplus/aestxyz_t
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true
ENV HOSTNAME z.paracamplus.net

WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80
RUN /root/RemoteScripts/setup.sh

#end.
