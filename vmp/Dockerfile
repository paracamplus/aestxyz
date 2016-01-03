#
#                          Building aestxyz-vmp
#
# Start a container running a proxy dedicated to be the portal for
# all CodeGradX universes.
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME p.paracamplus.com

WORKDIR /root/
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
