#
#                          Building aestxyz-vmx
#
# Start a container only running an X server
# its configuration is in root.d/opt/x.paracamplus.com/
#
# Run this on the docker host:
#   Docker/x.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME x.paracamplus.com

WORKDIR /root/
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
