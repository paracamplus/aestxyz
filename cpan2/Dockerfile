#
#                          Building aestxyz-cpan2
#
# It will add additional cpan modules.
#
FROM paracamplus/aestxyz_cpan
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-perl-modules.sh

#end.
