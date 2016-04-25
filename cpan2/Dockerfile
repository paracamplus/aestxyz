#
#                          Building aestxyz-cpan2
#
# It will add additional Debian packages and CPAN modules.
#
FROM paracamplus/aestxyz_cpan
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"

WORKDIR /root/
ADD RemoteScripts /root/RemoteScripts

# Caution: this will also update currently installed packages:
RUN /root/RemoteScripts/install-aptitude-packages.sh


RUN /root/RemoteScripts/install-perl-modules.sh

#end.
