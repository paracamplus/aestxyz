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
        --exclude='*\.qcow'  \
        --exclude='disk*\.qcow2'

# We start from a Debian7 image
docker.wheezy :
	docker pull 'debian:wheezy'

# Caution, we will be in / rather than /root/
start.wheezy :
	docker run --rm -it --name 'tmp-wheezy' 'debian:wheezy' '/bin/bash'

# NOTA: tags must respect only [a-z0-9_] are allowed, size between 4 and 30!

erase.all :
	-docker rm `docker ps -a -q`
	-docker rmi -f `docker images -q`

clean.useless :
	rm -f $$(find . -name '*~')
	rm -f $$(find . -name '*.bak')
	Scripts/remove-exited-containers.sh
	Scripts/remove-useless-images.sh
	df -h /var/lib/docker

start.squeeze :
	docker run --rm -it --name 'tmp-squeeze' 'debian:squeeze' '/bin/bash'

#recreate.all : erase.all
# Indentation figures inheritance:
recreate.all : clean.useless
recreate.all : create.aestxyz_apt
recreate.all :   create.aestxyz_cpan
#recreate.all :    create.aestxyz_a
#recreate.all :    create.aestxyz_e
#recreate.all :    create.aestxyz_s
#recreate.all :    create.aestxyz_x
#recreate.all :    create.aestxyz_t
#recreate.all :    create.aestxyz_z
#recreate.all :    create.aestxyz_y
recreate.all :     create.aestxyz_vmy
recreate.all :     create.aestxyz_vma
recreate.all :     create.aestxyz_vme
recreate.all :     create.aestxyz_vmx
recreate.all :     create.aestxyz_vmt
recreate.all :     create.aestxyz_vmz
# For the next ones: see do.li314
#recreate.all :     create.aestxyz_li314
#recreate.all :     create.aestxyz_li218
#recreate.all :     create.aestxyz_mooc-li101-2014fev
#recreate.all :     create.aestxyz_mooc-li101-2015mar
recreate.all :     create.aestxyz_vmms0
recreate.all :       create.aestxyz_vmms1
recreate.all :         create.aestxyz_vmms
recreate.all :     create.aestxyz_vmmd0
recreate.all :       create.aestxyz_vmmd1
#recreate.all : create.aestxyz_oldapt  # a6 with Debian6
#recreate.all : create.aestxyz_oldcpan # a6 with Debian6
#recreate.all : create.aestxyz_vmolda  # a6 with Debian6
# @bijou 87 min

deploy.all : deploy.y.paracamplus.com
deploy.all : deploy.a.paracamplus.com
deploy.all : deploy.a1.paracamplus.com
deploy.all : deploy.e.paracamplus.com
deploy.all : deploy.x.paracamplus.com
deploy.all : deploy.t.paracamplus.com
deploy.all : deploy.z.paracamplus.com
# For the next ones: see do.deploy.li314
#deploy.all : deploy.li314.paracamplus.com
#deploy.all : deploy.li218.paracamplus.com
#deploy.all : deploy.mooc-li101-2014fev.paracamplus.com
#deploy.all : deploy.mooc-li101-2015mar.paracamplus.com
#deploy.all : deploy.a6.paracamplus.com # with Debian6

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
	docker push 'paracamplus/aestxyz_apt'
# @bijou 27min

# and the other one with the required Perl modules:
create.aestxyz_cpan : cpan/Dockerfile
	cd cpan/ && docker build -t paracamplus/aestxyz_cpan .
	docker run --rm paracamplus/aestxyz_cpan perl -M'URL::Encode' -e 1
	docker run --rm paracamplus/aestxyz_cpan perl -M'Mail::Sendmail' -e 1
	docker run --rm paracamplus/aestxyz_cpan perl -MMoose -e 1
	docker tag paracamplus/aestxyz_cpan \
		"paracamplus/aestxyz_cpan:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_cpan paracamplus/aestxyz_base
# @bijou 65min
archive.aestxyz_cpan :
	docker push 'paracamplus/aestxyz_base'
# @bijou 4min
# paracamplus/aestxyz_base is the base image for all the next ones.

# Adjoin some new modules over aestxyz_cpan. 
# After testing, rebuild aestxyz_cpan.
create.aestxyz_cpan2 : cpan2/Dockerfile
	rsync -avu cpan/RemoteScripts/ cpan2/RemoteScripts/
	cd cpan2/ && docker build -t paracamplus/aestxyz_cpan2 .
	docker tag paracamplus/aestxyz_cpan2 \
		"paracamplus/aestxyz_cpan2:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_cpan2 paracamplus/aestxyz_base

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
tx1 :
# inner check of the X server:
	docker run --rm -h x.paracamplus.net \
		paracamplus/aestxyz_x \
		/root/RemoteScripts/check-inner-availability.sh \
			x.paracamplus.net
tx2 :
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

# ###########################################################################
# {{{ Images for servers in *.paracamplus.com
# A container with a single Y server in it.
create.aestxyz_vmy : vmy/Dockerfile
	vmy/y.paracamplus.com/prepare.sh
	cd vmy/ && docker build -t paracamplus/aestxyz_vmy .
	docker tag paracamplus/aestxyz_vmy \
		"paracamplus/aestxyz_vmy:$$(date +%Y%m%d_%H%M%S)"
# @bijou 1min
deploy.y.paracamplus.com :
	docker push 'paracamplus/aestxyz_vmy'
	rsync ${RSYNC_FLAGS} -avuL \
		y.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmy:latest'
	ssh -t root@ns353482.ovh.net Docker/y.paracamplus.com/install.sh
# FUTURE invent a good test for y!

# NOTA: this was a bad idea to put two different servers (A and E for
# instance) in the same container. Scripts are tailored for just one server!
# CAUTION: don't divulge fw4ex or ssh private keys.
create.aestxyz_vma : vma/Dockerfile
	vma/a.paracamplus.com/prepare.sh
	cd vma/ && docker build -t paracamplus/aestxyz_vma .
	docker tag paracamplus/aestxyz_vma \
		"paracamplus/aestxyz_vma:$$(date +%Y%m%d_%H%M%S)"
deploy.a.paracamplus.com :
	docker push 'paracamplus/aestxyz_vma'
	rsync ${RSYNC_FLAGS} -avuL \
		a.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vma:latest'
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
deploy.a1.paracamplus.com :
	docker push 'paracamplus/aestxyz_vma'
	rsync ${RSYNC_FLAGS} -avuL \
		a1.paracamplus.com Scripts root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net docker pull 'paracamplus/aestxyz_vma:latest'
	ssh -t root@ns327071.ovh.net Docker/a1.paracamplus.com/install.sh
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:51080/
	common/check-outer-availability.sh \
		-i a1.paracamplus.com -p 80 -s 4 \
		a1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 51022 -i Docker/a1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/a1.paracamplus.com/fw4excookie.insecure.key

create.aestxyz_vme : vme/Dockerfile
	vme/e.paracamplus.com/prepare.sh
	cd vme/ && docker build -t paracamplus/aestxyz_vme .
	docker tag paracamplus/aestxyz_vme \
		"paracamplus/aestxyz_vme:$$(date +%Y%m%d_%H%M%S)"
deploy.e.paracamplus.com :
	docker push 'paracamplus/aestxyz_vme'
	rsync ${RSYNC_FLAGS} -avuL \
	    e.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vme:latest'
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
	docker tag paracamplus/aestxyz_vmx \
		"paracamplus/aestxyz_vmx:$$(date +%Y%m%d_%H%M%S)"
deploy.x.paracamplus.com :
	docker push 'paracamplus/aestxyz_vmx'
	rsync ${RSYNC_FLAGS} -avuL \
	    x.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmx:latest'
	ssh -t root@ns353482.ovh.net Docker/x.paracamplus.com/install.sh -R
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:53080/
	common/check-outer-availability.sh \
		-i x.paracamplus.com -p 80 -s 4 \
		x.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 53022 -i Docker/x.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/x.paracamplus.com/fw4excookie.insecure.key
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 53022 -i Docker/x.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/x.paracamplus.com/dbuser_ecdsa

create.aestxyz_vmt : vmt/Dockerfile
	vmt/t.paracamplus.com/prepare.sh
	cd vmt/ && docker build -t paracamplus/aestxyz_vmt .
	docker tag paracamplus/aestxyz_vmt \
		"paracamplus/aestxyz_vmt:$$(date +%Y%m%d_%H%M%S)"
# T depends on X
deploy.t.paracamplus.com : 
	echo "Deploy t.paracamplus.com on OVHlicence"
	docker push 'paracamplus/aestxyz_vmt'
	rsync ${RSYNC_FLAGS} -avuL \
	    t.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmx:latest'
	ssh -t root@ns353482.ovh.net Docker/t.paracamplus.com/install.sh -R
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:54080/
	common/check-outer-availability.sh \
		-i t.paracamplus.com -p 80 -s 4 \
		t.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 54022 -i Docker/t.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/t.paracamplus.com/fw4excookie.insecure.key
	wget -qO /dev/stdout http://t.paracamplus.com/static/t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com/static//t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com//static/t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com//static//t.css | head

# Apache2 requires modules expire.load and proxy*
deploy.t9.paracamplus.com : 	
	echo "Deploy t9.paracamplus.com on Kimsufi"
	docker push 'paracamplus/aestxyz_vmt'
	rsync ${RSYNC_FLAGS} -avuL \
	    t9.paracamplus.com Scripts root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net docker pull 'paracamplus/aestxyz_vmx:latest'
	ssh -t root@ns327071.ovh.net Docker/t9.paracamplus.com/install.sh -R
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:54980/
	common/check-outer-availability.sh \
		-i t9.paracamplus.com -p 80 -s 4 \
		t9.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 54922 -i Docker/t9.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/t9.paracamplus.com/fw4excookie.insecure.key
	wget -qO /dev/stdout http://t9.paracamplus.com/static/t.css | head 
	wget -qO /dev/stdout http://t9.paracamplus.com/static//t.css | head 
	wget -qO /dev/stdout http://t9.paracamplus.com//static/t.css | head 
	wget -qO /dev/stdout http://t9.paracamplus.com//static//t.css | head 

create.aestxyz_vmz : vmz/Dockerfile
	vmz/z.paracamplus.com/prepare.sh
	cd vmz/ && docker build -t paracamplus/aestxyz_vmz .
	docker tag paracamplus/aestxyz_vmz \
		"paracamplus/aestxyz_vmz:$$(date +%Y%m%d_%H%M%S)"
deploy.z.paracamplus.com :
	docker push 'paracamplus/aestxyz_vmz'
	rsync ${RSYNC_FLAGS} -avuL \
	    z.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmz:latest'
	ssh -t root@ns353482.ovh.net Docker/z.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net \
		wget -qO /dev/stdout http':'//127.0.0.1:56080/
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

create.aestxyz_oldapt : oldapt/Dockerfile
	cd oldapt/ && docker build -t paracamplus/aestxyz_oldapt .
# aptitude update and upgrade are done. Perl is 5.10.1
	docker run --rm -it paracamplus/aestxyz_oldapt
create.aestxyz_oldcpan : oldcpan/Dockerfile
	cd oldcpan/RemoteScripts/ && tar czf root-A.tgz -C ../root.d/ .
	cd oldcpan/ && docker build -t paracamplus/aestxyz_oldcpan .
# should update /usr/{lib,share}/perl5 
#               /usr/{lib,share}/perl/5.10.1
# all directories mentioned in perl -V
# start vmplayer Debian6-64bit-VMfw4exForAuthor 172.16.82.128 to compare
create.aestxyz_vmolda : vmolda/Dockerfile
	vmolda/a6.paracamplus.com/prepare.sh
	cd vmolda/ && docker build -t paracamplus/aestxyz_vmolda .
	docker push 'paracamplus/aestxyz_vmolda:latest'
deploy.a6.paracamplus.com :
	rsync ${RSYNC_FLAGS} -avuL \
		a6.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmolda:latest'
	ssh -t root@ns353482.ovh.net Docker/a6.paracamplus.com/install.sh
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:57080/
	common/check-outer-availability.sh \
		-i a6.paracamplus.com -p 80 -s 4 \
		a6.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 57022 -i Docker/a6.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/a6.paracamplus.com/fw4excookie.insecure.key

create.aestxyz_vmms0 : vmms0/Dockerfile
# install debian packages and perl modules:
	chmod a+x vmms0/RemoteScripts/?*.sh
	vmms0/vmms0.paracamplus.com/prepare.sh
	cd vmms0/ && docker build -t paracamplus/aestxyz_vmms0 .
# @bijou: 26 min
create.aestxyz_vmms1 :
# install some languages with specific (non-debian) installations:
	chmod a+x vmms1/RemoteScripts/?*.sh
	vmms1/vmms1.paracamplus.com/prepare.sh
	cd vmms1/ && docker build -t paracamplus/aestxyz_vmms1 .
# @bijou: 11 min
create.aestxyz_vmms : vmms/Dockerfile
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	chmod a+x vmms/RemoteScripts/?*.sh
	vmms/vmms.paracamplus.com/prepare.sh
	cd vmms/ && docker build -t paracamplus/aestxyz_vmms .
#@bijou: 9 min
	docker tag paracamplus/aestxyz_vmms \
		"paracamplus/aestxyz_vmms:$$(date +%Y%m%d_%H%M%S)"
##	docker push 'paracamplus/aestxyz_vmms'
#@bijou: 300 min
test.local.vmms :
	-Scripts/remove-exited-containers.sh 
	-Scripts/remove-useless-images.sh
## check that the container has the right hostname:
	vmms.paracamplus.com/install.sh \
	    -e '/bin/hostname' </dev/null | \
		grep vmms.paracamplus.com
	sleep 2
## check that the container can be ssh-ed via its IP:
	vmms.paracamplus.com/install.sh -s 5 ; sleep 1
	ssh -i vmms.paracamplus.com/root \
		root@$$(cat vmms.paracamplus.com/docker.ip) hostname
	docker ps -l
## check that the local container can be ssh-ed via a tunnel:
	ssh -p 58022 -i vmms.paracamplus.com/root root@127.0.0.1 hostname
	docker ps -l
# run MD with a Docker MS:
tlv :
	./vmms.on.bijou/run.md.with.docker.ms.sh

fix.ssh.and.keys :
	-chown -R queinnec':' $$(find . -type d -name .ssh)
	-chown -R queinnec':' $$(find . -type f -name 'root*')
	-chown -R queinnec':' $$(find . -type f -name 'keys.t*')
	-rm -f */keys.txt */keys.tgz \
		*/root */root_rsa */root*.pub */rootfs \
		*/ssh_host_ecdsa_key.pub \
		*/nohup.out */docker.ip */docker.cid

deploy.vmms.on.ovhlicence : 
	docker push 'paracamplus/aestxyz_vmms'
	ssh -t root@ns353482.ovh.net \
		rm -f /home/queinnec/Paracamplus/ExerciseFrameWork-V2/Docker/vmms.paracamplus.com/ssh_host_ecdsa_key.pub
	ssh -t root@ns353482.ovh.net docker pull 'paracamplus/aestxyz_vmms:latest'
	chmod a+x vmms.on.ovhlicence/run.md.with.docker.ms.sh
	rsync -avu ${RSYNC_FLAGS} ${HOME}/Paracamplus ns353482.ovh.net':'
	ssh -t ns353482.ovh.net \
	  rsync -avu Paracamplus/ExerciseFrameWork/perllib/ \
		/usr/local/lib/site_perl/
	ssh -t root@ns353482.ovh.net \
	   /home/queinnec/Paracamplus/ExerciseFrameWork/Docker/vmms.on.ovhlicence/run.md.with.docker.ms.sh

deploy.vmms.on.youpou : 
	docker push 'paracamplus/aestxyz_vmms'
	chmod a+x vmms.on.youpou/run.md.with.docker.ms.sh
	rsync -avu ${RSYNC_FLAGS} ${HOME}/Paracamplus youpou.rsr.lip6.fr':'
	ssh -t youpou.rsr.lip6.fr \
	    /home/queinnec/Paracamplus/ExerciseFrameWork/Docker/vmms.on.youpou/run.md.with.docker.ms.sh

create.aestxyz_vmmd0 : vmmd0/Dockerfile
# install debian packages and perl modules:
	chmod a+x vmmd0/RemoteScripts/?*.sh
	vmmd0/vmmd0.paracamplus.com/prepare.sh
	cd vmmd0/ && docker build -t paracamplus/aestxyz_vmmd0 .
# @bijou: 15min
create.aestxyz_vmmd1 : vmmd/Dockerfile
# Restart from here when changing start*sh scripts!
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	chmod a+x vmmd/RemoteScripts/?*.sh
	vmmd/vmmd.paracamplus.com/prepare.sh
	cd vmmd/ && docker build -t paracamplus/aestxyz_vmmd1 .
# @bijou: 6min
create.aestxyz_vmmd : 
# Finish to prepare the fully complete paracamplus/aestxyz_vmmd image
# and mainly download last paracamplus/aestxyz_vmms image
	-docker stop vmmd
	-docker rm vmmd
	-docker stop vmmd1
	-docker rm vmmd1
	-docker stop vmmd0
	-docker rm vmmd0
	-docker rmi paracamplus/aestxyz_vmmd
	-Scripts/remove-exited-containers.sh 
	-Scripts/remove-useless-images.sh
	chmod a+x vmmd/RemoteScripts/?*.sh
	vmmd/vmmd.paracamplus.com/prepare.sh
	vmmd.paracamplus.com/install.sh -D QNC=1 -s 1
	Scripts/packVmmd.sh vmmd1 paracamplus/aestxyz_vmmd 
	docker stop vmmd1
	docker rm vmmd1
# 22 min, 7.2G
# docker push 'paracamplus/aestxyz_vmmd'

create.aestxyz_vmmdr :
# finish to prepare a complete MD in a Docker container without inner MS
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	vmmdr/vmmdr.paracamplus.com/prepare.sh
	cd vmmdr/ && docker build -t paracamplus/aestxyz_vmmdr .
	docker tag paracamplus/aestxyz_vmmdr \
		"paracamplus/aestxyz_vmmdr:$$(date +%Y%m%d_%H%M%S)"
# @bijou: 1 min
#	docker push 'paracamplus/aestxyz_vmmdr'
test.vmmdr :
	docker run --rm -it paracamplus/aestxyz_vmmdr
# run Docker MD with an external Docker MS:
tlmd :
	./vmmd.on.bijou/run.docker.md.with.docker.ms.sh

deploy.vmmdr+vmms.on.remote : 
	cd vmmdr+vmms.on.remote/ && m deploy

# Generate keys for the install procedure:
generate.install.keys :
	ssh-keygen -t rsa -N '' -b 2048 \
		-C 'vmmdr+vmms-transfer-key' \
		-f vmmdr.on.ovhlicence/vmmdr+vmms
	cd vmmdr.on.ovhlicence/ && mv vmmdr+vmms vmmdr+vmms.private.key
# This creates a -----BEGIN PUBLIC KEY-----
	cd vmmdr.on.ovhlicence/ && \
	    openssl rsa -in vmmdr+vmms.private.key \
		-pubout -outform pem > vmmdr+vmms.public.key
# whereas this creates an unworkable -----BEGIN RSA PUBLIC KEY-----
#	ssh-keygen -f vmmdr.on.ovhlicence/vmmdr+vmms.pub -e -m pem \
#		> vmmdr.on.ovhlicence/vmmdr+vmms.public.key
	rm -f vmmdr.on.ovhlicence/vmmdr+vmms.pub
	head vmmdr.on.ovhlicence/vmmdr+vmms.*.key

# Small patches to vmmd
create.aestxyz_vmmda :
	chmod a+x vmmda/RemoteScripts/?*.sh
	vmmda/vmmda.paracamplus.com/prepare.sh
	cd vmmda/ && docker build -t paracamplus/aestxyz_vmmda .

VMMD=vmmd
test.local.${VMMD} : 
	-docker stop vmmda
	-docker rm vmmda
	-docker stop vmmd
	-docker rm vmmd
	Scripts/remove-exited-containers.sh 
	Scripts/remove-useless-images.sh
	${VMMD}.paracamplus.com/install.sh
	sleep 2
	Scripts/connect.sh ${VMMD}
# within md
#     # check vmms is running
#     docker ps -a | grep vmms
#     docker logs vmms
# 

test.batch :
	export KEY=`pwd`/vmmdr.on.ovhlicence/vmmdr.paracamplus.com/root ;\
	cd ../Deployment/VMmd/Samples/Batch0/ && \
	m IP=127.0.0.1 IPPORT=61022 KEY=$$KEY send.batch

test.D.option.in.install.sh :
	vmms.paracamplus.com/install.sh -s 10 -D A=3 -o '-c printenv' | grep A=3
# @bijou: 2014nov25: OK


COURSE=ToBeDefined
do.course :
	if ! [ -d ${COURSE} ] ; then m instantiate_${COURSE} ; fi
	m create.aestxyz_${COURSE} 
	m deploy.${COURSE}.paracamplus.com 
instantiate_${COURSE} :
	bash -x ./Scripts/instantiate.sh ${COURSE}
create.aestxyz_${COURSE} : ${COURSE}/Dockerfile
	${COURSE}/${COURSE}.paracamplus.com/prepare.sh
	cd ${COURSE}/ && docker build -t paracamplus/aestxyz_${COURSE} .
	docker tag paracamplus/aestxyz_${COURSE} \
		"paracamplus/aestxyz_${COURSE}:$$(date +%Y%m%d_%H%M%S)"
# @bijou: < 80sec
# On deploie sur ovhlicence:
deploy.${COURSE}.paracamplus.com : 
	docker push 'paracamplus/aestxyz_${COURSE}'
	rsync ${RSYNC_FLAGS} -avuL \
	    ${COURSE}.paracamplus.com Scripts root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net \
		Docker/${COURSE}.paracamplus.com/install.sh -r
	host ${COURSE}.paracamplus.com
	common/check-outer-availability.sh \
		-i ${COURSE}.paracamplus.com -p 80 -s 4 \
		${COURSE}.paracamplus.com
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.paracamplus.com/static/fw4ex-281x282.png | wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.paracamplus.com/static//fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.paracamplus.com//static/fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.paracamplus.com//static//fw4ex-281x282.png| wc -c` ]
# On deploie sur kimsufi pour effectuer des tests:
deploy.test.${COURSE}.paracamplus.com : 
	docker push 'paracamplus/aestxyz_${COURSE}'
	rsync ${RSYNC_FLAGS} -avuL \
	    test.${COURSE}.paracamplus.com Scripts \
		root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net \
		Docker/test.${COURSE}.paracamplus.com/install.sh -r
	common/check-outer-availability.sh \
		-i test.${COURSE}.paracamplus.com -p 80 -s 4 \
		test.${COURSE}.paracamplus.com
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.paracamplus.com/static/fw4ex-281x282.png | wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.paracamplus.com/static//fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.paracamplus.com//static/fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.paracamplus.com//static//fw4ex-281x282.png| wc -c` ]

do.li314 :
	m do.course COURSE=li314
do.deploy.test.li314 :
	m deploy.test.li314.paracamplus.com COURSE=li314
do.li314_2013oct :
	m do.course COURSE=li314_2013oct
do.mooc-li101-2014fev :
	m do.course COURSE=mooc-li101-2014fev
do.mooc-li101-2015mar :
	m do.course COURSE=mooc-li101-2015mar
do.deploy.mooc-li101-2015mar :
	m deploy.mooc-li101-2015mar.paracamplus.com COURSE=mooc-li101-2015mar
do.deploy.test.mooc-li101-2015mar :
	m deploy.test.mooc-li101-2015mar.paracamplus.com COURSE=mooc-li101-2015mar
do.li218 :
	m do.course COURSE=li218

# }}}

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
