#
#                          Building aestxyz-vmy
#
# Start a container only running a Y server
# its configuration is in root.d/opt/y.paracamplus.com/
#
# Run this on the docker host:
#   Docker/y.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME y.paracamplus.com

WORKDIR /root/
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
