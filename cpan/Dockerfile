#
#                          Building aestxyz-cpan
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... but no specific FW4EX code.
#
FROM paracamplus/aestxyz_apt
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-perl-modules.sh

#end.
