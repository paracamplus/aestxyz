#
#                          Building aestxyz-vmms1
#
# Prepare the basic part of a container only running a Marking Slave
# (some programming languages with specific installation)
#
FROM paracamplus/aestxyz_vmms0
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmms1.paracamplus.com

WORKDIR /root/
ENV HOME /root/
ADD RemoteScripts /root/RemoteScripts

# Update Debian packages
RUN /root/RemoteScripts/install-aptitude-packages.sh /root/RemoteScripts/debian-modules-ms.txt

# Update Perl modules
RUN /root/RemoteScripts/install-perl-modules.sh /root/RemoteScripts/perl-modules-ms.txt

# install specific languages java, bigloo, racket
RUN /root/RemoteScripts/setup-22-languages.sh
# @bijou: 12 min

#end.
