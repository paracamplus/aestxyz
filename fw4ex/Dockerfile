#
#                          Building aestxyz-fw4ex
#
# It will contain all standard apt packages and cpan modules required to run 
# the various servers a, e, ... and specific FW4EX code.
#
FROM paracamplus/aestxyz_cpan
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV FW4EX_DOCKER true

WORKDIR /root/
ADD perllib.tgz                  /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts

RUN chown -R root: /usr/local/lib/site_perl/Paracamplus/

#end.
