#
#                          Building aestxyz-vmz
#
# Start a container running a proxy dedicated to one course
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME z.paracamplus.com

WORKDIR /root/
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

#end.
