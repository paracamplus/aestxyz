#
#                          Building aestxyz-vmmd
#
# Start a container running a vmmd Marking Driver
#
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmmd.paracamplus.com
WORKDIR /root/

ADD RemoteScripts /root/RemoteScripts
RUN /root/RemoteScripts/install-aptitude-packages.sh /root/RemoteScripts/debian-modules-md.txt

RUN /root/RemoteScripts/install-perl-modules.sh /root/RemoteScripts/perl-modules-md.txt

RUN bash -xc 'wget -qO- https://get.docker.io/ | sh'

ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD vmmd.paracamplus.com/root.d/ /

EXPOSE 22
RUN /root/RemoteScripts/setup.sh

#end.
