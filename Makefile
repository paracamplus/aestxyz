#     Creation of a Docker container for aestxyz

work : nothing 
clean :: cleanMakefile

# We start from a Debian7 image
docker.wheezy :
	docker pull 'debian:wheezy'

# Caution, we will be in / rather than /root/
start.wheezy :
	docker run --rm -it --name 'tmp:wheezy' 'debian:wheezy' '/bin/bash'

# NOTA: tags must respect only [a-z0-9_] are allowed, size between 4 and 30!

erase.all :
	-docker rm `docker ps -a -q`
	-docker rmi `docker images -q`

#recreate.all : erase.all
#recreate.all : create.aestxyz_apt
#recreate.all : create.aestxyz_cpan
recreate.all : create.aestxyz_fw4ex
recreate.all : create.aestxyz_a

# To ease tuning, let's create the base container in small steps
# one with the necessary Debian packages:
create.aestxyz_apt : apt/Dockerfile
	cd apt/ && docker build -t paracamplus/aestxyz_apt .
	docker run --rm paracamplus/aestxyz_apt pwd
	docker tag paracamplus/aestxyz_apt \
		"paracamplus/aestxyz_apt:$$(date +%Y%m%d_%H%M%S)"
# @bijou 19min
archive.aestxyz_apt :
	docker push paracamplus/aestxyz_apt
# @bijou 27min

# and the other one with the required Perl modules:
create.aestxyz_cpan : cpan/Dockerfile
	cd cpan/ && docker build -t paracamplus/aestxyz_cpan .
	docker run --rm paracamplus/aestxyz_cpan perl -MMoose -e 1
	docker tag paracamplus/aestxyz_cpan \
		"paracamplus/aestxyz_cpan:$$(date +%Y%m%d_%H%M%S)"
# @bijou 63min
archive.aestxyz_cpan :
	docker push paracamplus/aestxyz_cpan
# @bijou 4min

# install Paracamplus/FW4EX perl modules:
create.aestxyz_fw4ex : fw4ex/Dockerfile	
	tar czf fw4ex/perllib.tgz -C ../perllib \
	  $$( cd ../perllib/ && find Paracamplus -name '*.pm' )
	cd fw4ex/ && docker build -t paracamplus/aestxyz_fw4ex .
	docker run --rm paracamplus/aestxyz_fw4ex \
	   ls -l /usr/local/lib/site_perl/Paracamplus/FW4EX/
	docker tag paracamplus/aestxyz_fw4ex \
		"paracamplus/aestxyz_fw4ex:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_fw4ex \
		"paracamplus/aestxyz_fw4ex:latest"

# These are CPAN modules required to run prepare.sh on the Docker host:
local.ensure.cpan :
	cpan String::Escape String::Random Data::Serializer
	cpan Crypt::OpenSSL::RSA File::Slurp XML::DOM YAML
	cpan JavaScript::Minifier

# Install an A server:  a.paracamplus.net
create.aestxyz_a : a/Dockerfile
	a/a.paracamplus.net/prepare.sh
	cd a/ && docker build -t paracamplus/aestxyz_a .
# @bijou 1min
# inner check of the A server:
	docker run --rm -h a.paracamplus.net \
		paracamplus/aestxyz_a \
		/root/RemoteScripts/check-inner-availability.sh
# outer check of the A server:
	docker run -d -p '127.0.0.1:50080:80' -h a.paracamplus.net \
	    paracamplus/aestxyz_a \
	    /root/RemoteScripts/start.sh -s 30 && \
	  a/a.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4
	docker tag paracamplus/aestxyz_a \
		"paracamplus/aestxyz_a:$$(date +%Y%m%d_%H%M%S)"

# Install an E server:  e.paracamplus.net
create.aestxyz_e : e/Dockerfile
	e/e.paracamplus.net/prepare.sh
	cd e/ && docker build -t paracamplus/aestxyz_e .
# @bijou 


# let start the sshd daemon:
create.aestxyz_daemons : daemons/Dockerfile
	cd daemons/ && docker build -t paracamplus/aestxyz_daemons .
create.aestxyz_base :
	docker tag paracamplus/aestxyz_daemons paracamplus/aestxyz_base
run.aestxyz-base : 
	docker run -it --rm -p '127.0.0.1:50022:22' \
		paracamplus/aestxyz_base /bin/bash
start.aestxyz-base :
	docker run -d -p '127.0.0.1:50022:22' paracamplus/aestxyz_base \
	    sleep $$(( 60 * 60 * 24 * 365 * 10 ))


# end of Makefile
