#
#                          Building aestxyz-vmt
#
# Start a container only running a T server
# its configuration is in root.d/opt/t.paracamplus.com/
#
# Run this on the docker host:
#   Docker/t.paracamplus.com/install.sh
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME t.paracamplus.com

WORKDIR /root/
ADD perllib.tgz                  /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
