#
#                          Building aestxyz-vmz
#
# Start a container running a proxy dedicated to one course
#
FROM paracamplus/aestxyz_fw4ex
MAINTAINER ChristianQueinnec "christian.queinnec@paracamplus.com"
ENV HOSTNAME z.paracamplus.com
WORKDIR /root/
ADD RemoteScripts                /root/RemoteScripts
EXPOSE 80 22
RUN /root/RemoteScripts/setup.sh
#end.
