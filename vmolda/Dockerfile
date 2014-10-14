#
#                          Building aestxyz-vmolda
#
# This is a variant of aestxyz-vma with Debian6 not Debian7.
#
FROM paracamplus/aestxyz_oldcpan
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME a6.paracamplus.com

WORKDIR /root/
ADD perllib.tgz                  /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts
RUN chown -R root: /usr/local/lib/site_perl/Paracamplus/

EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh

# patches:
RUN aptitude install logrotate

#end.
