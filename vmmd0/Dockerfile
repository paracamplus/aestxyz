#
#                          Building aestxyz-vmmd0
#
# base for a vmmd container
#
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmmd0.paracamplus.com
WORKDIR /root/

ADD RemoteScripts /root/RemoteScripts

RUN /root/RemoteScripts/install-aptitude-packages.sh /root/RemoteScripts/debian-modules-md.txt

RUN /root/RemoteScripts/install-perl-modules.sh /root/RemoteScripts/perl-modules-md.txt

#end.
