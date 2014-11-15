#
#                          Building aestxyz-mooc-li101-2014fev
#
# Start a container running a proxy dedicated to one course
#
FROM paracamplus/aestxyz_base
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME mooc-li101-2014fev.paracamplus.com
WORKDIR /root/
RUN cpan Catalyst::Plugin::CustomErrorMessage
ADD RemoteScripts/perllib.tgz    /usr/local/lib/site_perl/
ADD RemoteScripts                /root/RemoteScripts
EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh
#end.
