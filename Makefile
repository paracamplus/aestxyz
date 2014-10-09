#     Creation of a Docker container for aestxyz
# We install all the softwares required to instantiate
#   vmauthor
#   proxying frontend
#   a,e,t servers

work : nothing 
clean :: cleanMakefile

RSYNC_FLAGS     =     \
        --exclude RCS \
        --exclude CVS \
        --exclude .svn \
        --exclude .hg \
        --exclude .git \
        --exclude Archive \
        --exclude='.DS_Store' \
        --exclude='*~' \
        --exclude='.\#*' \
        --exclude='\#*\#' \
        --exclude='*.bak' \
        --exclude='*.sql.gz' \
        --exclude='disk*\.qcow2' 

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

clean.useless :
	rm -f $$(find . -name '*~')
	rm -f $$(find . -name '*.bak')

#recreate.all : erase.all
recreate.all : clean.useless
#recreate.all : create.aestxyz_apt
#recreate.all : create.aestxyz_cpan
recreate.all : create.aestxyz_fw4ex
recreate.all : create.aestxyz_a
recreate.all : create.aestxyz_e
recreate.all : create.aestxyz_s
recreate.all : create.aestxyz_x
recreate.all : create.aestxyz_t
recreate.all : create.aestxyz_z
recreate.all : create.aestxyz_y
recreate.all : create.aestxyz_vmy
recreate.all : create.aestxyz_vma
recreate.all : create.aestxyz_vme
recreate.all : create.aestxyz_vmx
recreate.all : create.aestxyz_vmt
recreate.all : create.aestxyz_vmz
#recreate.all : adjoin.docker.io
# @bijou 87 min

deploy.all : deploy.y.paracamplus.com
deploy.all : deploy.a.paracamplus.com
deploy.all : deploy.e.paracamplus.com
deploy.all : deploy.x.paracamplus.com
deploy.all : deploy.t.paracamplus.com
deploy.all : deploy.z.paracamplus.com
deploy.all : deploy.li314.paracamplus.com

# {{{ Base images
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
# paracamplus/aestxyz_fw4ex is the base image for all the next ones.

# These are CPAN modules required to run prepare.sh on the Docker host:
local.ensure.cpan :
	cpan String::Escape String::Random Data::Serializer
	cpan Crypt::OpenSSL::RSA File::Slurp XML::DOM YAML
	cpan JavaScript::Minifier

# }}}

# {{{ Local images for local tests
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
# inner check of the E server:
	docker run --rm -h e.paracamplus.net \
		paracamplus/aestxyz_e \
		/root/RemoteScripts/check-inner-availability.sh \
			e.paracamplus.net
# outer check of the E server:
	docker run -d -p '127.0.0.1:50080:80' -h e.paracamplus.net \
	    paracamplus/aestxyz_e \
	    /root/RemoteScripts/start.sh -s 10 && \
	  e/e.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		e.paracamplus.net
	docker tag paracamplus/aestxyz_e \
		"paracamplus/aestxyz_e:$$(date +%Y%m%d_%H%M%S)"

# Install an S server: s.paracamplus.net
# S is not a Catalyst webapp
create.aestxyz_s : s/Dockerfile
	s/s.paracamplus.net/prepare.sh
	cd s/ && docker build -t paracamplus/aestxyz_s .
# inner check of the S server:
	docker run --rm -h s.paracamplus.net \
		paracamplus/aestxyz_s \
		/root/RemoteScripts/check-inner-availability.sh \
			 s.paracamplus.net
# outer check of the S server:
	docker run -d -p '127.0.0.1:50080:80' -h s.paracamplus.net \
	    paracamplus/aestxyz_s \
	    /root/RemoteScripts/start.sh -s 10 && \
	  s/s.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		s.paracamplus.net
	docker tag paracamplus/aestxyz_s \
		"paracamplus/aestxyz_s:$$(date +%Y%m%d_%H%M%S)"

# Install an X server: x.paracamplus.net
# requires access to the database
create.aestxyz_x : x/Dockerfile
	x/x.paracamplus.net/prepare.sh
	cd x/ && docker build -t paracamplus/aestxyz_x .
# inner check of the X server:
	docker run --rm -h x.paracamplus.net \
		paracamplus/aestxyz_x \
		/root/RemoteScripts/check-inner-availability.sh \
			x.paracamplus.net
# outer check of the X server:
	docker run -d -p '127.0.0.1:50080:80' -h x.paracamplus.net \
	    paracamplus/aestxyz_x \
	    /root/RemoteScripts/start.sh -s 10 && \
	  x/x.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		x.paracamplus.net
	docker tag paracamplus/aestxyz_x \
		"paracamplus/aestxyz_x:$$(date +%Y%m%d_%H%M%S)"

# Install a T server: t.paracamplus.net
# T proxies to the previous servers
create.aestxyz_t : t/Dockerfile
	t/t.paracamplus.net/prepare.sh
	cd t/ && docker build -t paracamplus/aestxyz_t .
# inner check of the T server:
	docker run --rm -h t.paracamplus.net \
		paracamplus/aestxyz_t \
		/root/RemoteScripts/check-inner-availability.sh \
			t.paracamplus.net
# outer check of the T server:
	docker run -d -p '127.0.0.1:50080:80' -h t.paracamplus.net \
	    paracamplus/aestxyz_t \
	    /root/RemoteScripts/start.sh -s 10 && \
	  t/t.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		t.paracamplus.net
	docker tag paracamplus/aestxyz_t \
		"paracamplus/aestxyz_t:$$(date +%Y%m%d_%H%M%S)"

# Install a Z server: z.paracamplus.net
create.aestxyz_z : z/Dockerfile
	z/z.paracamplus.net/prepare.sh
	cd z/ && docker build -t paracamplus/aestxyz_z .
# inner check of the Z server:
	docker run --rm -h z.paracamplus.net \
		paracamplus/aestxyz_z \
		/root/RemoteScripts/check-inner-availability.sh \
			z.paracamplus.net
# outer check of the Z server:
	docker run -d -p '127.0.0.1:50080:80' -h z.paracamplus.net \
	    paracamplus/aestxyz_z \
	    /root/RemoteScripts/start.sh -s 10 && \
	  z/z.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		z.paracamplus.net
	docker tag paracamplus/aestxyz_z \
		"paracamplus/aestxyz_z:$$(date +%Y%m%d_%H%M%S)"

# Install a Y server: y.paracamplus.net
create.aestxyz_y : y/Dockerfile
	y/y.paracamplus.net/prepare.sh
	cd y/ && docker build -t paracamplus/aestxyz_y .
# inner check of the Y server:
	docker run --rm -h y.paracamplus.net \
		paracamplus/aestxyz_y \
		/root/RemoteScripts/check-inner-availability.sh \
			y.paracamplus.net 
# outer check of the Y server:
	docker run -d -p '127.0.0.1:50080:80' -h y.paracamplus.net \
	    paracamplus/aestxyz_y \
	    /root/RemoteScripts/start.sh -s 10 && \
	  y/y.paracamplus.net/check-outer-availability.sh \
		-i 127.0.0.1 -p 50080 -s 4 \
		y.paracamplus.net
	docker tag paracamplus/aestxyz_y \
		"paracamplus/aestxyz_y:$$(date +%Y%m%d_%H%M%S)"
# }}}

# {{{ Images for servers in *.paracamplus.com
# A container with a single Y server in it.
create.aestxyz_vmy : vmy/Dockerfile
	vmy/y.paracamplus.com/prepare.sh
	cd vmy/ && docker build -t paracamplus/aestxyz_vmy .
	docker push paracamplus/aestxyz_vmy
# @bijou 1min
deploy.y.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
		y.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/y.paracamplus.com/install.sh
	y/y.paracamplus.net/check-outer-availability.sh \
		-i y.paracamplus.com -p 80 -s 4 \
		y.paracamplus.com

# NOTA: this was a bad idea to put two different servers (A and E for
# instance) in the same container. Scripts are tailored for just one server!
# A container with an A server in it.
# CAUTION: don't divulge fw4ex or ssh private keys.
create.aestxyz_vma : vma/Dockerfile
	vma/a.paracamplus.com/prepare.sh
	cd vma/ && docker build -t paracamplus/aestxyz_vma .
	docker push paracamplus/aestxyz_vma
deploy.a.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
		a.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/a.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:51080/
	common/check-outer-availability.sh \
		-i a.paracamplus.com -p 80 -s 4 \
		a.paracamplus.com
	common/check-outer-availability.sh \
		-i a0.paracamplus.com -p 80 -s 4 \
		a0.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 51022 -i Docker/a.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/a.paracamplus.com/fw4excookie.insecure.key

create.aestxyz_vme : vme/Dockerfile
	vme/e.paracamplus.com/prepare.sh
	cd vme/ && docker build -t paracamplus/aestxyz_vme .
	docker push paracamplus/aestxyz_vme
deploy.e.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
	    e.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/e.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:52080/
	common/check-outer-availability.sh \
		-i e.paracamplus.com -p 80 -s 4 \
		e.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 52022 -i Docker/e.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/e.paracamplus.com/fw4excookie.insecure.key

# Caution: take care of the size of the Apache logs!!!!!!!!!!

create.aestxyz_vmx : vmx/Dockerfile
	vmx/x.paracamplus.com/prepare.sh
	cd vmx/ && docker build -t paracamplus/aestxyz_vmx .
	docker push paracamplus/aestxyz_vmx
deploy.x.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
	    x.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/x.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:53080/
	common/check-outer-availability.sh \
		-i x.paracamplus.com -p 80 -s 4 \
		x.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 53022 -i Docker/x.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/x.paracamplus.com/fw4excookie.insecure.key

create.aestxyz_vmt : vmt/Dockerfile
	vmt/t.paracamplus.com/prepare.sh
	cd vmt/ && docker build -t paracamplus/aestxyz_vmt .
	docker push paracamplus/aestxyz_vmt
deploy.t.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
	    t.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/t.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:54080/
	common/check-outer-availability.sh \
		-i t.paracamplus.com -p 80 -s 4 \
		t.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 54022 -i Docker/t.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/t.paracamplus.com/fw4excookie.insecure.key
	wget -qO /dev/stdout http://t.paracamplus.com/static/t.css
	wget -qO /dev/stdout http://t.paracamplus.com/static//t.css
	wget -qO /dev/stdout http://t.paracamplus.com//static/t.css
	wget -qO /dev/stdout http://t.paracamplus.com//static//t.css

create.aestxyz_vmz : vmz/Dockerfile
	vmz/z.paracamplus.com/prepare.sh
	cd vmz/ && docker build -t paracamplus/aestxyz_vmz .
	docker push paracamplus/aestxyz_vmz
deploy.z.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
	    z.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/z.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:56080/
	common/check-outer-availability.sh \
		-i z.paracamplus.com -p 80 -s 4 \
		z.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 56022 -i Docker/z.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/z.paracamplus.com/fw4excookie.insecure.key
	wget -qO /dev/stdout http://z.paracamplus.com/static/z.css
	wget -qO /dev/stdout http://z.paracamplus.com/static//z.css
	wget -qO /dev/stdout http://z.paracamplus.com//static/z.css
	wget -qO /dev/stdout http://z.paracamplus.com//static//z.css

COURSE=li314
instantiate_${COURSE} :
	./Scripts/instantiate.sh ${COURSE}
create.aestxyz_${COURSE} : ${COURSE}/Dockerfile
	${COURSE}/${COURSE}.paracamplus.com/prepare.sh
	cd ${COURSE}/ && docker build -t paracamplus/aestxyz_${COURSE} .
	docker push paracamplus/aestxyz_${COURSE}
deploy.${COURSE}.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
	    ${COURSE}.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/${COURSE}.paracamplus.com/install.sh
	common/check-outer-availability.sh \
		-i ${COURSE}.paracamplus.com -p 80 -s 4 \
		${COURSE}.paracamplus.com
# }}}

create.aestxyz_vmauthor : vmauthor/Dockerfile
	vmauthor/vmauthor.paracamplus.net/prepare.sh
	cd vmauthor/ && docker build -t paracamplus/aestxyz_vmauthor .


# Install many exercises in this E server. Should be done after all
# servers are installed in the container.
fill.exercises :
	echo to be done ; exit 3

adjoin.docker.io : dockerio/Dockerfile
	cd dockerio/ && docker build -t paracamplus/aestxyz_dockerio .
# FIXME how to run docker within docker ?????????????????????????????????
#	docker run --rm paracamplus/aestxyz_dockerio \
#		/root/RemoteScripts/check-docker.sh
	docker tag paracamplus/aestxyz_dockerio \
		"paracamplus/aestxyz_dockerio:$$(date +%Y%m%d_%H%M%S)"

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
