#     Creation of a Docker container for aestxyz
# We install all the softwares required to instantiate
#   vmauthor
#   proxying frontend
#   a,e,t servers

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
	-docker rmi -f `docker images -q`

#recreate.all : erase.all
#recreate.all : create.aestxyz_apt
#recreate.all : create.aestxyz_cpan
#recreate.all : adjoin.docker.io
recreate.all : create.aestxyz_fw4ex
recreate.all : create.aestxyz_a
recreate.all : create.aestxyz_e
recreate.all : create.aestxyz_s
recreate.all : create.aestxyz_x
recreate.all : create.aestxyz_t
recreate.all : create.aestxyz_z
recreate.all : create.aestxyz_y
recreate.all : create.aestxyz_vmy
# @bijou 87 min

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

adjoin.docker.io : dockerio/Dockerfile
	cd dockerio/ && docker build -t paracamplus/aestxyz_dockerio .
# FIXME how to run docker within docker ?????????????????????????????????
#	docker run --rm paracamplus/aestxyz_dockerio \
#		/root/RemoteScripts/check-docker.sh
	docker tag paracamplus/aestxyz_dockerio \
		"paracamplus/aestxyz_dockerio:$$(date +%Y%m%d_%H%M%S)"

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
		/root/RemoteScripts/check-inner-availability.sh \
			a.paracamplus.net
# outer check of the A server:
	docker run -d -p '127.0.0.1:50080:80' -h a.paracamplus.net \
	    paracamplus/aestxyz_a \
	    /root/RemoteScripts/start.sh -s 10 && \
	  a/a.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		a.paracamplus.net
	docker tag paracamplus/aestxyz_a \
		"paracamplus/aestxyz_a:$$(date +%Y%m%d_%H%M%S)"

# Install an E server:  e.paracamplus.net
create.aestxyz_e : e/Dockerfile
	e/e.paracamplus.net/prepare.sh
	cd e/ && docker build -t paracamplus/aestxyz_e .
# @bijou 
# inner check of the E and A servers:
	docker run --rm -h e.paracamplus.net \
		paracamplus/aestxyz_e \
		/root/RemoteScripts/check-inner-availability.sh \
			e.paracamplus.net a.paracamplus.net 
# outer check of the E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h e.paracamplus.net \
	    paracamplus/aestxyz_e \
	    /root/RemoteScripts/start.sh -s 10 && \
	  e/e.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_e \
		"paracamplus/aestxyz_e:$$(date +%Y%m%d_%H%M%S)"

# Install an S server: s.paracamplus.net
# S is not a Catalyst webapp
create.aestxyz_s : s/Dockerfile
	s/s.paracamplus.net/prepare.sh
	cd s/ && docker build -t paracamplus/aestxyz_s .
# inner check of the S, E and A servers:
	docker run --rm -h s.paracamplus.net \
		paracamplus/aestxyz_s \
		/root/RemoteScripts/check-inner-availability.sh \
			 s.paracamplus.net e.paracamplus.net a.paracamplus.net  
# outer check of the S, E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h s.paracamplus.net \
	    paracamplus/aestxyz_s \
	    /root/RemoteScripts/start.sh -s 10 && \
	  s/s.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		s.paracamplus.net e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_s \
		"paracamplus/aestxyz_s:$$(date +%Y%m%d_%H%M%S)"

# Install an X server: x.paracamplus.net
# requires access to the database
create.aestxyz_x : x/Dockerfile
	x/x.paracamplus.net/prepare.sh
	cd x/ && docker build -t paracamplus/aestxyz_x .
# inner check of the X, S, E and A servers:
	docker run --rm -h x.paracamplus.net \
		paracamplus/aestxyz_x \
		/root/RemoteScripts/check-inner-availability.sh \
			x.paracamplus.net \
			s.paracamplus.net e.paracamplus.net a.paracamplus.net  
# outer check of the X, S, E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h x.paracamplus.net \
	    paracamplus/aestxyz_x \
	    /root/RemoteScripts/start.sh -s 10 && \
	  x/x.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		x.paracamplus.net \
		s.paracamplus.net e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_x \
		"paracamplus/aestxyz_x:$$(date +%Y%m%d_%H%M%S)"

# Install a T server: t.paracamplus.net
# T proxies to the previous servers
create.aestxyz_t : t/Dockerfile
	t/t.paracamplus.net/prepare.sh
	cd t/ && docker build -t paracamplus/aestxyz_t .
# inner check of the T, X, S, E and A servers:
	docker run --rm -h t.paracamplus.net \
		paracamplus/aestxyz_t \
		/root/RemoteScripts/check-inner-availability.sh \
			t.paracamplus.net x.paracamplus.net \
			s.paracamplus.net e.paracamplus.net a.paracamplus.net  
# outer check of the T, X, S, E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h t.paracamplus.net \
	    paracamplus/aestxyz_t \
	    /root/RemoteScripts/start.sh -s 10 && \
	  t/t.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		t.paracamplus.net x.paracamplus.net \
		s.paracamplus.net e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_t \
		"paracamplus/aestxyz_t:$$(date +%Y%m%d_%H%M%S)"

# Install a Z server: z.paracamplus.net
create.aestxyz_z : z/Dockerfile
	z/z.paracamplus.net/prepare.sh
	cd z/ && docker build -t paracamplus/aestxyz_z .
# inner check of the Z, T, X, S, E and A servers:
	docker run --rm -h z.paracamplus.net \
		paracamplus/aestxyz_z \
		/root/RemoteScripts/check-inner-availability.sh \
			z.paracamplus.net t.paracamplus.net x.paracamplus.net \
			s.paracamplus.net e.paracamplus.net a.paracamplus.net  
# outer check of the Z, T, X, S, E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h z.paracamplus.net \
	    paracamplus/aestxyz_z \
	    /root/RemoteScripts/start.sh -s 10 && \
	  z/z.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		z.paracamplus.net t.paracamplus.net x.paracamplus.net \
		s.paracamplus.net e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_z \
		"paracamplus/aestxyz_z:$$(date +%Y%m%d_%H%M%S)"

# Install a Y server: y.paracamplus.net
create.aestxyz_y : y/Dockerfile
	y/y.paracamplus.net/prepare.sh
	cd y/ && docker build -t paracamplus/aestxyz_y .
# inner check of the Y, Z, T, X, S, E and A servers:
	docker run --rm -h y.paracamplus.net \
		paracamplus/aestxyz_y \
		/root/RemoteScripts/check-inner-availability.sh \
			y.paracamplus.net \
			z.paracamplus.net t.paracamplus.net x.paracamplus.net \
			s.paracamplus.net e.paracamplus.net a.paracamplus.net  
# outer check of the Y, Z, T, X, S, E and A servers:
	docker run -d -p '127.0.0.1:50080:80' -h y.paracamplus.net \
	    paracamplus/aestxyz_y \
	    /root/RemoteScripts/start.sh -s 10 && \
	  y/y.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		y.paracamplus.net \
		z.paracamplus.net t.paracamplus.net x.paracamplus.net \
		s.paracamplus.net e.paracamplus.net a.paracamplus.net
	docker tag paracamplus/aestxyz_y \
		"paracamplus/aestxyz_y:$$(date +%Y%m%d_%H%M%S)"

# A container with a single Y server in it.
create.aestxyz_vmy : vmy/Dockerfile
	vmy/vmy.paracamplus.net/prepare.sh
	cd vmy/ && docker build -t paracamplus/aestxyz_vmy .
deploy.y.paracamplus.com :
	docker push paracamplus/aestxyz_vmy
# @bijou 
	rsync -avu y.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/y.paracamplus.com/install.sh
	y/y.paracamplus.net/check-outer-availability.sh \
		-i y.paracamplus.com -p 80 -s 4 \
		y.paracamplus.com

# A container with an A and E servers in it.
create.aestxyz_vmae : vmae/Dockerfile
	vmae/vmae.paracamplus.net/prepare.sh
	cd vmae/ && docker build -t paracamplus/aestxyz_vmae .
deploy.ae.paracamplus.com :
#	docker push paracamplus/aestxyz_vmae
	rsync -avu ae.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/ae.paracamplus.com/install.sh
	a/a.paracamplus.net/check-outer-availability.sh \
		-i a.paracamplus.com -p 80 -s 4 \
		a.paracamplus.com
	e/e.paracamplus.net/check-outer-availability.sh \
		-i e.paracamplus.com -p 80 -s 4 \
		e.paracamplus.com





create.aestxyz_vmauthor : vmauthor/Dockerfile
	vmauthor/vmauthor.paracamplus.net/prepare.sh
	cd vmauthor/ && docker build -t paracamplus/aestxyz_vmauthor .


# Install many exercises in this E server. Should be done after all
# servers are installed in the container.
fill.exercises :
	echo to be done ; exit 3

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
