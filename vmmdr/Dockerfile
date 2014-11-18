#
#                          Building aestxyz-vmmdr
#
# Start a container running a vmmd Marking Driver without inner MS
# NOTA: don't start from vmmd1 that contains an inner Docker.
#
FROM paracamplus/aestxyz_vmmd0
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME vmmdr.paracamplus.com
WORKDIR /root/
ENV HOME /root/
ENV USER root

ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts
ADD vmmdr.paracamplus.com/root.d/ /

EXPOSE 22
RUN /root/RemoteScripts/setup.sh

#end.
