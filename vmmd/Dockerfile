#
#                          Building aestxyz-vmmd
#
# Start a container running a vmmd Marking Driver
#
FROM paracamplus/aestxyz_vmmd0
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmmd.paracamplus.com
WORKDIR /root/

RUN bash -xc 'wget -qO- https://get.docker.io/ | sh'

ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts
ADD vmmd.paracamplus.com/root.d/ /

EXPOSE 22
RUN /root/RemoteScripts/setup.sh

#end.
