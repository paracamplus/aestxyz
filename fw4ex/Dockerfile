#
#                          Building aestxyz-fw4ex
#
# Install FW4EX Perl modules
#
FROM paracamplus/aestxyz_dockerio
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true

WORKDIR /root/
ADD perllib.tgz                  /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

RUN chown -R root: /usr/local/lib/site_perl/Paracamplus/

#end.
