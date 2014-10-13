#
#                          Building aestxyz-oldcpan
#
# This is a variant of aestxyz-cpan with Debian6 not Debian7.
#
FROM paracamplus/aestxyz_oldapt
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts                /root/RemoteScripts

RUN /root/RemoteScripts/install-oldperl-modules.sh

#end.
