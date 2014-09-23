#
#                          Building aestxyz-cpan2
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... but no specific FW4EX code.
#
FROM paracamplus/aestxyz_cpan
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true

WORKDIR /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-forced-perl-modules.sh

#end.
