#     Creation of a Docker container for aestxyz

work : nothing 
clean :: cleanMakefile

# We start from a Debian7 image
docker.wheezy :
	docker pull 'debian:wheezy'

# Caution, we will be in / rather than /root/
start.wheezy :
	docker run -it --name 'tmp:wheezy' 'debian:wheezy' '/bin/bash'

# NOTA: tags must respect only [a-z0-9_] are allowed, size between 4 and 30!

erase.all :
	docker rm `docker ps -a -q`
	docker rmi `docker images -q`

# To ease tuning, let's create the base container in small steps
# one with the necessary Debian packages:
create.aestxyz_apt : apt/Dockerfile
	cd apt/ && docker build -t paracamplus/aestxyz_apt .
	docker run paracamplus/aestxyz_apt pwd
	docker tag paracamplus/aestxyz_apt \
		"paracamplus/aestxyz_apt:$$(date +%Y%m%d_%H%M%S)"
# @bijou 19min
archive.aestxyz_apt :
	docker push paracamplus/aestxyz_apt
# @bijou 27min

# and the other one with the required Perl modules:
create.aestxyz_cpan : cpan/Dockerfile
	cd cpan/ && docker build -t paracamplus/aestxyz_cpan .
	docker run paracamplus/aestxyz_cpan perl -MMoose -e 1
	docker tag paracamplus/aestxyz_cpan \
		"paracamplus/aestxyz_cpan:$$(date +%Y%m%d_%H%M%S)"
# @bijou 63min
# There is one module that must|should be forced:
adjoin.aestxyz_cpan :
	cd cpan2/ && docker build -t paracamplus/aestxyz_cpan2 .
	docker run paracamplus/aestxyz_cpan2 perl -MFilesys::DiskUsage -e 1
	docker tag paracamplus/aestxyz_cpan2 \
		"paracamplus/aestxyz_cpan2:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_cpan2 \
		"paracamplus/aestxyz_cpan:latest"
# @bijou 
archive.aestxyz_cpan :
	docker push paracamplus/aestxyz_cpan
# @bijou 4min

# let start the sshd daemon:
create.aestxyz_daemons : daemons/Dockerfile
	cd daemons/ && docker build -t paracamplus/aestxyz_daemons .
create.aestxyz_base :
	docker tag paracamplus/aestxyz_daemons paracamplus/aestxyz_base
run.aestxyz-base : 
	docker run -it -p '127.0.0.1:50022:22' paracamplus/aestxyz_base /bin/bash
start.aestxyz-base :
	docker run -d -p '127.0.0.1:50022:22' paracamplus/aestxyz_base \
	    sleep $$(( 60 * 60 * 24 * 365 * 10 ))


# end of Makefile
