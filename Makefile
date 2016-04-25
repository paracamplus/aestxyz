#     Creation of a Docker container for aestxyz
# We install all the softwares required to instantiate
#   vmauthor
#   proxying frontend
#   a,e,t servers

# NOTA: In Docker: the “Latest” tag simply means “the last build/tag
# that ran without a specific tag/version specified”.
# cf. https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375#.37i232ewu

work : nothing 
clean :: cleanMakefile

OVHLICENCE	=	ns353482.ovh.net
KIMSUFI		=	ns327071.ovh.net

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

#REPOSITORY=registry-1.docker.io
REPOSITORY=www.paracamplus.com:5000

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
# See              create.aestxyz_cpan2 for missing packages or modules!
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
#recreate.all :     create.aestxyz_mooc-li101-2015unsa
#recreate.all :     create.aestxyz_jfp7
recreate.all :     create.aestxyz_vmms0
recreate.all :       create.aestxyz_vmms1
recreate.all :         create.aestxyz_vmms
recreate.all :     create.aestxyz_vmmd0
recreate.all :       create.aestxyz_vmmd1
recreate.all :       create.aestxyz_vmmdr
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
deploy.all : deploy.t9.paracamplus.com
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
	cd apt/ && docker build -t paracamplus/aestxyz_apt:latest .
	docker run --rm paracamplus/aestxyz_apt pwd
	docker tag paracamplus/aestxyz_apt:latest \
		${REPOSITORY}/"paracamplus/aestxyz_apt:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_apt:latest \
		${REPOSITORY}/"paracamplus/aestxyz_apt:latest"
# @bijou 19min
archive.aestxyz_apt :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_apt:latest'
# @bijou 27min

# and the other one with the required Perl modules:
create.aestxyz_cpan : cpan/Dockerfile
	cd cpan/ && docker build -t paracamplus/aestxyz_cpan:latest .
	docker run --rm paracamplus/aestxyz_cpan perl -M'URL::Encode' -e 1
	docker run --rm paracamplus/aestxyz_cpan perl -M'Mail::Sendmail' -e 1
	docker run --rm paracamplus/aestxyz_cpan perl -MMoose -e 1
	docker tag paracamplus/aestxyz_cpan:latest \
		${REPOSITORY}/"paracamplus/aestxyz_cpan:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_cpan:latest \
		${REPOSITORY}/"paracamplus/aestxyz_cpan:latest"
	docker tag paracamplus/aestxyz_cpan:latest \
		${REPOSITORY}/paracamplus/aestxyz_base:latest
# @bijou 65min
archive.aestxyz_cpan :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_base':latest
# @bijou 4min
# paracamplus/aestxyz_base is the base image for all the next ones.

# ######## Sometimes some new Debian packages or Perl modules are needed.
# Modify common/{debian-modules.txt,perl-modules.txt}
# ATTENTION, some modules are only needed by the Marking Slave (see vmms below)
# Create a new container and then tag it as paracamplus/aestxyz_base
create.aestxyz_cpan2 : cpan2/Dockerfile
	touch cpan2/Dockerfile
	rsync -avu cpan/RemoteScripts/ cpan2/RemoteScripts/
	rsync -avu common/?*-modules.txt cpan2/RemoteScripts/
	cd cpan2/ && docker build -t paracamplus/aestxyz_cpan2:latest .
	docker tag paracamplus/aestxyz_cpan2:latest \
		${REPOSITORY}/"paracamplus/aestxyz_cpan2:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_cpan2:latest \
		${REPOSITORY}/paracamplus/aestxyz_cpan2:latest
	docker tag paracamplus/aestxyz_cpan2:latest \
		${REPOSITORY}/paracamplus/aestxyz_base:latest

create.aestxyz_base3 : base3/Dockerfile
	touch base3/Dockerfile
	mkdir -p base3/RemoteScripts
	cp remote-common/start-91-removeXapian.sh base3/RemoteScripts/
	cd base3/ && docker build -t paracamplus/aestxyz_base3:latest .
	docker tag paracamplus/aestxyz_base3:latest \
	    ${REPOSITORY}/"paracamplus/aestxyz_base3:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_base3:latest \
	    ${REPOSITORY}/paracamplus/aestxyz_base3:latest
	docker tag paracamplus/aestxyz_base3:latest \
	    ${REPOSITORY}/paracamplus/aestxyz_base:latest

# }}}

# ###########################################################################
# {{{ Images for servers in *.paracamplus.com
# A container with a single Y server in it.
create.aestxyz_vmy : vmy/Dockerfile
	vmy/y.paracamplus.com/prepare.sh
	cd vmy/ && docker build -t paracamplus/aestxyz_vmy:latest .
	docker tag paracamplus/aestxyz_vmy:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmy:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmy:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmy:latest"
# @bijou 1min
deploy.y.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmy':latest
	rsync ${RSYNC_FLAGS} -avuL \
		Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		y.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/y.paracamplus.com/install.sh -r
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout \
		http':'//127.0.0.1:50080/
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout \
		http':'//127.0.0.1:50080/alive
	common/check-outer-availability.sh \
		-i y.paracamplus.com -p 80 -s 4 -u '/alive' \
		y.paracamplus.com
	@echo "           Y.PARACAMPLUS.COM DEPLOYED"


# NOTA: this was a bad idea to put two different servers (A and E for
# instance) in the same container. Scripts are tailored for just one server!
# CAUTION: don't divulge fw4ex or ssh private keys.
create.aestxyz_vma : vma/Dockerfile
	vma/a.paracamplus.com/prepare.sh
	cd vma/ && docker build -t paracamplus/aestxyz_vma:latest .
	docker tag paracamplus/aestxyz_vma:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vma:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vma:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vma:latest"
# deploy a and a0 simultaneously:
deploy.a.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vma':latest
	rsync ${RSYNC_FLAGS} -avuL \
		Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		a.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/a.paracamplus.com/install.sh -r
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
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://a0.paracamplus.com/jobload' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus Acquisition Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep load
# Should be served directly by Apache:
	curl -D /tmp/a 'http://a0.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 a' < /tmp/a
	if grep 'Server: Paracamplus Acquisition Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://a0.paracamplus.com/static/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 A' < /tmp/a
	if grep 'Server: Paracamplus Acquisition Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
	@echo "           A. AND A0.PARACAMPLUS.COM DEPLOYED"
deploy.a1.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vma':latest
	rsync ${RSYNC_FLAGS} -avuL \
		Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		a1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/a1.paracamplus.com/install.sh -r
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:51080/
	common/check-outer-availability.sh \
		-i a1.paracamplus.com -p 80 -s 4 \
		a1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 51022 -i Docker/a1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/a.paracamplus.com/fw4excookie.insecure.key
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://a1.paracamplus.com/jobload' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus Acquisition Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep load
# Should be served directly by Apache:
	curl -D /tmp/a 'http://a1.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 a' < /tmp/a
	if grep 'Server: Paracamplus Acquisition Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://a1.paracamplus.com/static/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 A' < /tmp/a
	if grep 'Server: Paracamplus Acquisition Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           A1.PARACAMPLUS.COM DEPLOYED"

create.aestxyz_vme : vme/Dockerfile
	vme/e.paracamplus.com/prepare.sh
	cd vme/ && docker build -t paracamplus/aestxyz_vme:latest .
	docker tag paracamplus/aestxyz_vme:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vme:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vme:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vme:latest"
deploy.e.vld7net.fr :
	cd e.vld7net.fr ; m run.local
deploy.e.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vme':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		e.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/e.paracamplus.com/install.sh -r
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:52080/
	common/check-outer-availability.sh \
		-i e.paracamplus.com -p 80 -s 4 \
		e.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 52022 -i Docker/e.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/e.paracamplus.com/fw4excookie.insecure.key
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://e0.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://e0.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 e' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://e0.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 E' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           E. and E0.PARACAMPLUS.COM DEPLOYED"
deploy.e1.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vme':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    e1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/e1.paracamplus.com/install.sh -r
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:52080/
	common/check-outer-availability.sh \
		-i e1.paracamplus.com -p 80 -s 4 \
		e1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 52022 -i Docker/e1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/e.paracamplus.com/fw4excookie.insecure.key
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://e1.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://e1.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 e' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://e1.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 E' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           E1.PARACAMPLUS.COM DEPLOYED"

# Caution: take care of the size of the Apache logs!!!!!!!!!!

create.aestxyz_vmx : vmx/Dockerfile
	vmx/x.paracamplus.com/prepare.sh
	cd vmx/ && docker build -t paracamplus/aestxyz_vmx:latest .
	docker tag paracamplus/aestxyz_vmx:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmx:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmx:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmx:latest"
deploy.x.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmx':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    x.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/x.paracamplus.com/install.sh -r
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:53080/
	common/check-outer-availability.sh \
		-i x.paracamplus.com -p 80 -s 4 \
		x.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 53022 -i Docker/x.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/x.paracamplus.com/fw4excookie.insecure.key
	-rm -f /tmp/a /tmp/b
	curl -D /tmp/a 'http://x.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
	-rm -f /tmp/a /tmp/b
	curl -D /tmp/a 'http://x.paracamplus.com/dbalive' >/tmp/b 2>/dev/null
	grep 'HTTP/1.1 200' < /tmp/a
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
	@echo "           X.PARACAMPLUS.COM DEPLOYED"
deploy.x1.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmx':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    x1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/x1.paracamplus.com/install.sh -r
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout \
		http':'//127.0.0.1:53980/
	common/check-outer-availability.sh \
		-i x1.paracamplus.com -p 80 -s 4 \
		x1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 53922 -i Docker/x1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/x.paracamplus.com/fw4excookie.insecure.key
	-rm -f /tmp/a /tmp/b
	curl -D /tmp/a 'http://x1.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep epoch < /tmp/b
	-rm -f /tmp/a /tmp/b
# x1 n'a pas acces a la base ???
	curl -D /tmp/a 'http://x1.paracamplus.com/dbalive' >/tmp/b 2>/dev/null
	grep 'HTTP/1.1 200' < /tmp/a
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep epoch < /tmp/b
	@echo "           X1.PARACAMPLUS.COM DEPLOYED"
deploy.x.vld7net.fr :
	cd x.vld7net.fr ; m run.local

create.aestxyz_vmt : vmt/Dockerfile
	vmt/t.paracamplus.com/prepare.sh
	cd vmt/ && docker build -t paracamplus/aestxyz_vmt:latest .
	docker tag paracamplus/aestxyz_vmt:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmt:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmt:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmt:latest"
# T depends on X but does not need access to the database.
deploy.t.paracamplus.com : 
	echo "Deploy t.paracamplus.com on OVHlicence"
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmt':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    t.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/t.paracamplus.com/install.sh -r
	wget -qO /dev/stdout http://t.paracamplus.com/static/t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com/static//t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com//static/t.css | head 
	wget -qO /dev/stdout http://t.paracamplus.com//static//t.css | head
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://t.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 t' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 T' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           T.PARACAMPLUS.COM DEPLOYED"

# Apache2 requires modules expire.load and proxy*
deploy.t1.paracamplus.com : 	
	echo "Deploy t1.paracamplus.com on Kimsufi"
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmt':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    t1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/t1.paracamplus.com/install.sh -r
	wget -qO /dev/stdout http://t1.paracamplus.com/static/t.css | head 
	wget -qO /dev/stdout http://t1.paracamplus.com/static//t.css | head 
	wget -qO /dev/stdout http://t1.paracamplus.com//static/t.css | head 
	wget -qO /dev/stdout http://t1.paracamplus.com//static//t.css | head
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://t1.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t1.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 t' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t1.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 T' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           T1.PARACAMPLUS.COM DEPLOYED"

deploy.t2.codegradx.org : 	
	echo "Deploy t2.codegradx.org on Kimsufi"
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmt':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    t2.codegradx.org root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/t2.codegradx.org/install.sh -r
	wget -qO /dev/stdout http://t2.codegradx.org/static/t.css | head 
	wget -qO /dev/stdout http://t2.codegradx.org/static//t.css | head 
	wget -qO /dev/stdout http://t2.codegradx.org//static/t.css | head 
	wget -qO /dev/stdout http://t2.codegradx.org//static//t.css | head
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://t2.codegradx.org/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t2.codegradx.org/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 t' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://t2.codegradx.org/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 T' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           T2.CODEGRADX.ORG DEPLOYED"

create.aestxyz_vmz : vmz/Dockerfile
	vmz/z.paracamplus.com/prepare.sh
	cd vmz/ && docker build -t paracamplus/aestxyz_vmz:latest .
	docker tag paracamplus/aestxyz_vmz:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmz:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmz:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmz:latest"
deploy.z.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmz':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    z.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/z.paracamplus.com/install.sh -r
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
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://z.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://z.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 z' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://z.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 Z' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           Z0 and Z.PARACAMPLUS.COM DEPLOYED"
deploy.z1.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmz':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    z1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/z1.paracamplus.com/install.sh -r
	ssh -t root@ns327071.ovh.net \
		wget -qO /dev/stdout http':'//127.0.0.1:56080/
	common/check-outer-availability.sh \
		-i z1.paracamplus.com -p 80 -s 4 \
		z1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 56022 -i Docker/z1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/z.paracamplus.com/fw4excookie.insecure.key
	wget -qO /dev/stdout http://z1.paracamplus.com/static/z.css
	wget -qO /dev/stdout http://z1.paracamplus.com/static//z.css
	wget -qO /dev/stdout http://z1.paracamplus.com//static/z.css
	wget -qO /dev/stdout http://z1.paracamplus.com//static//z.css
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://z1.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus . Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep epoch
# Should be served directly by Apache:
	curl -D /tmp/a 'http://z1.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 z' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://z1.paracamplus.com/static/cookiechoices.min.js' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 Z' < /tmp/a
	if grep 'Server: Paracamplus . Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ; fi
	@echo "           Z1.PARACAMPLUS.COM DEPLOYED"

# Portal for CodeGradX
create.aestxyz_vmp : vmp/Dockerfile
	cd /usr/local/bin/ && sudo ln -sf node-0.12.7 ./node
	vmp/p.paracamplus.com/prepare.sh
	cd vmp/ && docker build -t paracamplus/aestxyz_vmp:latest .
	docker tag paracamplus/aestxyz_vmp:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmp:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmp:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmp:latest"
run.p.vld7net.fr : 
	cd p.vld7net.fr ; m run.local
deploy.p.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmp:latest'
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    p.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/p.paracamplus.com/install.sh -r

create.aestxyz_vmd : vma/Dockerfile
	vmd/d.paracamplus.com/prepare.sh
	cd vmd/ && docker build -t paracamplus/aestxyz_vmd:latest .
	docker tag paracamplus/aestxyz_vmd:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmd:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmd:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmd:latest"
deploy.d.vld7net.fr :
	cd d.vld7net.fr/ && m run.local
# deploy d and d0 simultaneously:
deploy.d.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmd':latest
	rsync ${RSYNC_FLAGS} -avuL \
		Scripts root@ns353482.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		d.paracamplus.com root@ns353482.ovh.net':'Docker/
	ssh -t root@ns353482.ovh.net Docker/d.paracamplus.com/install.sh -r
	ssh -t root@ns353482.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:59080/
	common/check-outer-availability.sh \
		-i d.paracamplus.com -p 80 -s 4 \
		d.paracamplus.com
	common/check-outer-availability.sh \
		-i d0.paracamplus.com -p 80 -s 4 \
		d0.paracamplus.com
	ssh -t root@ns353482.ovh.net \
	  ssh -v -p 59022 -i Docker/d.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/d.paracamplus.com/fw4excookie.insecure.key
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://d0.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus .* Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep now
# Should be served directly by Apache:
	curl -D /tmp/a 'http://d0.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 d' < /tmp/a
	if grep 'Server: Paracamplus .* Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://d0.paracamplus.com/static/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 D' < /tmp/a
	if grep 'Server: Paracamplus Datastore Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
	@echo "           D. AND D0.PARACAMPLUS.COM DEPLOYED"
deploy.d1.paracamplus.com :
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmd':latest
	rsync ${RSYNC_FLAGS} -avuL \
		Scripts root@ns327071.ovh.net':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
		d1.paracamplus.com root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net Docker/d1.paracamplus.com/install.sh -r
	ssh -t root@ns327071.ovh.net wget -qO /dev/stdout http':'//127.0.0.1:59080/
	common/check-outer-availability.sh \
		-i d1.paracamplus.com -p 80 -s 4 \
		d1.paracamplus.com
	ssh -t root@ns327071.ovh.net \
	  ssh -v -p 59022 -i Docker/d1.paracamplus.com/root_rsa \
		root@127.0.0.1 \
		ls -l /opt/d.paracamplus.com/fw4excookie.insecure.key
# Should be served by Catalyst+Starman proxied by Apache:
	curl -D /tmp/a 'http://d1.paracamplus.com/alive' >/tmp/b 2>/dev/null
	grep 'Server: Paracamplus .* Server' < /tmp/a
	grep 'Content-Type: application/json' < /tmp/a
	grep '{' < /tmp/b | grep now
# Should be served directly by Apache:
	curl -D /tmp/a 'http://d1.paracamplus.com/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 d' < /tmp/a
	if grep 'Server: Paracamplus .* Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
# Should be served directly by Apache:
	curl -D /tmp/a 'http://d1.paracamplus.com/static/favicon.ico' >/tmp/b 2>/dev/null
	grep 'X-originator: Apache2 D' < /tmp/a
	if grep 'Server: Paracamplus Datastore Server' < /tmp/a ;\
		then exit 1 ; else exit 0 ;fi
	@echo "           D1.PARACAMPLUS.COM DEPLOYED"

create.aestxyz_vmms0 : vmms0/Dockerfile
# install debian packages and perl modules:
	chmod a+x vmms0/RemoteScripts/?*.sh
	vmms0/vmms0.paracamplus.com/prepare.sh
	cd vmms0/ && docker build -t paracamplus/aestxyz_vmms0:latest .
# @bijou: 111 min
create.aestxyz_vmms1 : vmms1/Dockerfile
# install some languages with specific (non-debian) installations:
	chmod a+x vmms1/RemoteScripts/?*.sh
	cp -pf vmms0/RemoteScripts/*.txt vmms1/RemoteScripts/
	cp -pf vmms0/RemoteScripts/setup-90-checkMS.sh vmms1/RemoteScripts/
	vmms1/vmms1.paracamplus.com/prepare.sh
	cd vmms1/ && docker build -t paracamplus/aestxyz_vmms1:latest .
# @bijou: 12 min
create.aestxyz_vmms : vmms/Dockerfile
	ln -sf vmmdr+vmms.on.remote/vmms.paracamplus.com .
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	cp -pf vmms0/RemoteScripts/setup-90-checkMS.sh vmms/RemoteScripts/
	chmod a+x vmms/RemoteScripts/?*.sh
	vmms/vmms.paracamplus.com/prepare.sh
	cd vmms/ && docker build -t paracamplus/aestxyz_vmms:latest .
#@bijou: 9 min
	docker tag paracamplus/aestxyz_vmms:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmms:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmms:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmms:latest"
#  Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmms':latest
#@bijou: 300 min, 26min (avec fibre)
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

# How to add some new programs to vmms
# Modify vmms1/RemoteScripts/debian-module-ms.txt 
#    and vmms1/RemoteScripts/perl-module-ms.txt 
#    and vmms1/RemoteScripts/setup-22-languages.sh
#    and vmms1/RemoteScripts/npm-modules-ms.txt 
# rebuild vmms0 with m create.aestxyz_vmms0
# rebuild vmms1 with m create.aestxyz_vmms1
# rebuild vmms  with m create.aestxyz_vmms


fix.ssh.and.keys :
	-chown -R queinnec':' $$(find . -type d -name .ssh)
	-chown -R queinnec':' $$(find . -type f -name 'root*')
	-chown -R queinnec':' $$(find . -type f -name 'keys.t*')
	-rm -f */keys.txt */keys.tgz \
		*/root */root_rsa */root*.pub */rootfs \
		*/ssh_host_ecdsa_key.pub \
		*/nohup.out */docker.ip */docker.cid

deploy.vmms.on.ovhlicence : 
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmms':latest
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
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmms':latest
	chmod a+x vmms.on.youpou/run.md.with.docker.ms.sh
	rsync -avu ${RSYNC_FLAGS} ${HOME}/Paracamplus youpou.rsr.lip6.fr':'
	ssh -t youpou.rsr.lip6.fr \
	    /home/queinnec/Paracamplus/ExerciseFrameWork/Docker/vmms.on.youpou/run.md.with.docker.ms.sh

squash.vmms :
	time docker save 'paracamplus/aestxyz_vmms:latest' > /tmp/vmms.tar
# 4.1G 
	time sudo /usr/local/src/docker-squash -i /tmp/vmms.tar \
	  -o /tmp/vmms-squashed.tar \
	  -t 'paracamplus/aestxyz_vmms_squashed:latest'
# 3.3G 13 min
	ls -l /tmp/vmms*.tar
	time docker load -i /tmp/vmms-squashed.tar

create.aestxyz_vmmd0 : vmmd0/Dockerfile
# install debian packages and perl modules:
	chmod a+x vmmd0/RemoteScripts/?*.sh
	vmmd0/vmmd0.paracamplus.com/prepare.sh
	cd vmmd0/ && docker build -t paracamplus/aestxyz_vmmd0:latest .
	docker tag paracamplus/aestxyz_vmmd0:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmmd0:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmmd0:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmmd0:latest"
# @bijou: 102 min!
create.aestxyz_vmmd1 : vmmd/Dockerfile
# Restart from here when changing start*sh scripts!
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	chmod a+x vmmd/RemoteScripts/?*.sh
	vmmd/vmmd.paracamplus.com/prepare.sh
	cd vmmd/ && docker build -t paracamplus/aestxyz_vmmd1:latest .
# @bijou: 6min
create.aestxyz_vmmd : 
# Finish to prepare the fully complete paracamplus/aestxyz_vmmd image
# and mainly download last paracamplus/aestxyz_vmms image. I now
# prefer to use vmmdr (with a separate (rather than inner) vmms).
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
# Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmmd':latest

create.aestxyz_vmmdr :
# finish to prepare a complete MD in a Docker container without inner MS
# vmmdr only depends on vmmd0
	ln -sf vmmdr+vmms.on.remote/vmmdr.paracamplus.com .
	-cd ../CPANmodules/FW4EXagent/ && m distribution
	vmmdr/vmmdr.paracamplus.com/prepare.sh
	cd vmmdr/ && docker build -t paracamplus/aestxyz_vmmdr:latest .
	docker tag paracamplus/aestxyz_vmmdr:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmmdr:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_vmmdr:latest \
		${REPOSITORY}/"paracamplus/aestxyz_vmmdr:latest"
# @bijou: 1 min
# Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmmdr':latest
# NOTA: added setup-90-hackShuffle.sh to avoid rebuilding vmmd0 HACK HACK HACK
test.vmmdr :
	docker run --rm -it paracamplus/aestxyz_vmmdr
# run Docker MD with an external Docker MS:
tlmd :
	./vmmdr.on.bijou/run.docker.md.with.docker.ms.sh
# Replace running vmmdr on bijou 
tlmd2:
	-mkdir -p /tmp/Docker/vmmdr+vmms.on.remote
	cp -p vmmdr+vmms.on.remote/monitor.sh /tmp/Docker/vmmdr+vmms.on.remote/
	sudo /tmp/Docker/vmmdr+vmms.on.remote/monitor.sh start

#REMOTE	=	ns353482.ovh.net
REMOTE	=	ns327071.ovh.net
REMOTEUSER	=	fw4ex
deploy.vmmdr+vmms.on.all.remote :
	for REMOTE in ns353482.ovh.net ns327071.ovh.net ; do\
	   make deploy.vmmdr+vmms.on.remote REMOTE=$$REMOTE ; done
deploy.vmmdr+vmms.on.remote :
	ssh ${REMOTEUSER}@${REMOTE} "mkdir -p Docker"
	chmod a+x Scripts/?*.sh
	rsync -avuL Scripts vmmdr+vmms.on.remote/ \
	    ${REMOTEUSER}@${REMOTE}':'Docker/

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
	cd vmmda/ && docker build -t paracamplus/aestxyz_vmmda:latest .

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
DOMAIN=paracamplus.com
do.course :
	if ! [ -d ${COURSE} ] ; then m instantiate_${COURSE} ; fi
	m create.aestxyz_${COURSE} 
	m deploy.${COURSE}.${DOMAIN} 
instantiate_${COURSE} : find.unused.port
	bash -x ./Scripts/instantiate.sh ${COURSE} '000'
create.aestxyz_${COURSE} : ${COURSE}/Dockerfile
	${COURSE}/${COURSE}.${DOMAIN}/prepare.sh
	cd ${COURSE}/ && docker build -t paracamplus/aestxyz_${COURSE}:latest .
	docker tag paracamplus/aestxyz_${COURSE}:latest \
		${REPOSITORY}/"paracamplus/aestxyz_${COURSE}:$$(date +%Y%m%d_%H%M%S)"
	docker tag paracamplus/aestxyz_${COURSE}:latest \
		${REPOSITORY}/"paracamplus/aestxyz_${COURSE}:latest"
# @bijou: < 80sec
# On deploie sur ovhlicence:
deploy.${COURSE}.${DOMAIN} : 
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_${COURSE}:latest'
	rsync ${RSYNC_FLAGS} -avuL \
	    Scripts root@${REMOTE}':'Docker/
	rsync ${RSYNC_FLAGS} -avuL --delete \
	    ${COURSE}.${DOMAIN} root@${REMOTE}':'Docker/
	ssh -t root@${REMOTE} \
		Docker/${COURSE}.${DOMAIN}/install.sh -r
	host ${COURSE}.${DOMAIN}
	common/check-outer-availability.sh \
		-i ${COURSE}.${DOMAIN} -p 80 -s 4 \
		${COURSE}.${DOMAIN}
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.${DOMAIN}/static/fw4ex-281x282.png | wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.${DOMAIN}/static//fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.${DOMAIN}//static/fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://${COURSE}.${DOMAIN}//static//fw4ex-281x282.png| wc -c` ]
	curl http':'//${COURSE}.${DOMAIN}/dbalive 2>/dev/null | grep '"dbalive":1'
	@echo "     ${COURSE}.${DOMAIN} DEPLOYED"
# On deploie sur kimsufi pour effectuer des tests:
deploy.test.${COURSE}.${DOMAIN} : 
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_${COURSE}':latest
	rsync ${RSYNC_FLAGS} -avuL \
	    test.${COURSE}.${DOMAIN} Scripts \
		root@ns327071.ovh.net':'Docker/
	ssh -t root@ns327071.ovh.net \
		Docker/test.${COURSE}.${DOMAIN}/install.sh -r
	common/check-outer-availability.sh \
		-i test.${COURSE}.${DOMAIN} -p 80 -s 4 \
		test.${COURSE}.${DOMAIN}
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.${DOMAIN}/static/fw4ex-281x282.png | wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.${DOMAIN}/static//fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.${DOMAIN}//static/fw4ex-281x282.png| wc -c` ]
	[ 4000 -eq `wget -qO /dev/stdout http://test.${COURSE}.${DOMAIN}//static//fw4ex-281x282.png| wc -c` ]
	curl http':'//${COURSE}.${DOMAIN}/dbalive 2>/dev/null | grep '"dbalive":1'
	@echo "     test.${COURSE}.${DOMAIN} DEPLOYED"

minify.js.files :
	cd ${HOME}/Paracamplus/ExerciseFrameWork/Servers/w.li101/ && \
		m minify.files

do.li218 :
	m do.course COURSE=li218
do.li314 :
	m do.course COURSE=li314
do.jfp7 :
	m do.course COURSE=jfp7
#	   m create.aestxyz_jfp7 COURSE=jfp7 
# cf setup-50-cpan for additional packages and perl modules...........
do.deploy.jfp7 :
	COURSE=jfp7 m deploy.jfp7.paracamplus.com COURSE=jfp7
do.deploy.test.li314 :
	m deploy.test.li314.paracamplus.com COURSE=li314
do.mooc-li101-2014fev : minify.js.files
	m do.course COURSE=mooc-li101-2014fev
do.mooc-li101-2015mar : minify.js.files
	m do.course COURSE=mooc-li101-2015mar
#	 m create.aestxyz_mooc-li101-2015mar COURSE=mooc-li101-2015mar
do.mooc-li101-2015unsa : minify.js.files
	m do.course COURSE=mooc-li101-2015unsa
do.pobj : minify.js.files
	cd ../Exercises/ && m pack.new.exercises.and.make.links 
	m do.course COURSE=pobj
do.deploy.mooc-li101-2015mar : minify.js.files
	m deploy.mooc-li101-2015mar.paracamplus.com COURSE=mooc-li101-2015mar
do.deploy.mooc-li101-2015unsa : minify.js.files
	m deploy.mooc-li101-2015unsa.paracamplus.com COURSE=mooc-li101-2015unsa
do.deploy.test.mooc-li101-2015mar : minify.js.files
	m deploy.test.mooc-li101-2015mar.paracamplus.com \
		COURSE=mooc-li101-2015mar

#create.insta2 :
#	mkdir -p insta2/
#	rsync -avu mooc-li101-2015mar/ insta2/
#	mv insta2/mooc*.paracamplus.com insta2/insta2.${DOMAIN}
#   etc.
do.insta2 :
	m do.course COURSE=insta2 REMOTE=ns327071.ovh.net
do.deploy.insta2.codegradx.org : minify.js.files
	m deploy.insta2.codegradx.org COURSE=insta2 DOMAIN=codegradx.org \
		REMOTE=ns327071.ovh.net
do.deploy.insta2.${DOMAIN} : minify.js.files
	m deploy.insta2.${DOMAIN} COURSE=insta2 \
		REMOTE=ns327071.ovh.net

# create jfp8
#  mkdir jfp8 ; rsync -avu jfp7/ jfp8/
#  rgrep -l jfp7 jfp8/
#  find jfp8 | grep jfp7
do.jfp8 :
	cd ${HOME}/Paracamplus/ExerciseFrameWork/Servers/JFP/ && \
		m minify.files
	m do.course COURSE=jfp8 REMOTE=ns353482.ovh.net
#	   m create.aestxyz_jfp8 COURSE=jfp8
# cf setup-50-cpan for additional packages and perl modules...........
do.deploy.jfp8 :
	m deploy.jfp8.paracamplus.com COURSE=jfp8 REMOTE=${OVHLICENCE}

# ################### les nouveaux serveurs 
do.scm :
	m do.course COURSE=scm REMOTE=ns327071.ovh.net
do.deploy.scm : minify.js.files
	m deploy.scm.paracamplus.com COURSE=scm REMOTE=ns327071.ovh.net
do.js :
	m do.course COURSE=js REMOTE=ns327071.ovh.net
do.deploy.js : minify.js.files
	m deploy.js.paracamplus.com COURSE=js REMOTE=ns327071.ovh.net
do.unx :
	m do.course COURSE=unx REMOTE=ns327071.ovh.net
do.deploy.unx : minify.js.files
	m deploy.unx.paracamplus.com COURSE=unx REMOTE=ns327071.ovh.net
do.jfp :
	m do.course COURSE=jfp REMOTE=ns327071.ovh.net
do.deploy.jfp : minify.js.files
	m deploy.jfp.paracamplus.com COURSE=jfp REMOTE=ns327071.ovh.net

# ########################## explore private docker repository
explore.private.repository :
	@echo 'mot de passe pour Docker Paracamplus registry'
	docker run -d \
		-e ENV_DOCKER_REGISTRY_HOST=www.paracamplus.com \
		-e ENV_DOCKER_REGISTRY_PORT=5000 \
		-e ENV_DOCKER_REGISTRY_USE_SSL=1 \
		-p 8080:80 \
		--name kkdrf \
		konradkleine/docker-registry-frontend:v2
	@echo '         now read       lynx http://localhost:8080/'
	@echo '         when finished  docker kill kkdrf'

# ######## find an unused port
find.unused.port :
	grep HOSTPORT */config.sh | \
	sed -ne '/PORT=/s/^\(.*\):\(.*\)$$/\2:\1/p' | sort

fill.private.registry :
	for n in a e p t x y z ; do \
		time docker tag paracamplus/aestxyz_vm$${n} \
			${REPOSITORY}/paracamplus/aestxyz_vm$${n} ; \
	Scripts/	timedocker.sh push ${REPOSITORY}/paracamplus/aestxyz_vm$${n} ; \
	done
	for n in apt base cpan jfp js scm unx li314 li218 \
			insta2 mooc-li101-2014fev mooc-li101-2015mar ; do \
		time docker tag paracamplus/aestxyz_$${n} \
			${REPOSITORY}/paracamplus/aestxyz_$${n} ; \
	Scripts/	timedocker.sh push ${REPOSITORY}/paracamplus/aestxyz_$${n} ; \
	done

# }}}

# Change in safecookie implies regenerating all running servers
recreate.all.running.servers :
	for kind in a e x z t mdr ms ; do \
		m create.aestxyz_vm$$kind ; done
redeploy.all.running.servers :
	for kind in a1 a e1 e x1 x t1 t z ; do \
		m deploy.$${kind}.paracamplus.com ; done
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmms':latest
	Scripts/dockerpush.sh ${REPOSITORY}/'paracamplus/aestxyz_vmmdr':latest
	m deploy.vmmdr+vmms.on.all.remote
	for kind in li314 li314_2013oct li218 mooc-li101-2014fev \
		test.mooc-li101-2015mar mooc-li101-2015mar mooc-li101-2015unsa ; do \
	  m do.$$kind ; done

create.aestxyz_vmauthor : vmauthor/Dockerfile
	vmauthor/vmauthor.paracamplus.net/prepare.sh
	cd vmauthor/ && docker build -t paracamplus/aestxyz_vmauthor:latest .


# Install many exercises in this E server. Should be done after all
# servers are installed in the container.
fill.exercises :
	echo to be done ; exit 3

# let start the sshd daemon:
create.aestxyz_daemons : daemons/Dockerfile
	cd daemons/ && docker build -t paracamplus/aestxyz_daemons:latest .
create.aestxyz_base :
	docker tag paracamplus/aestxyz_daemons:latest \
		${REPOSITORY}/paracamplus/aestxyz_base:latest
run.aestxyz-base : 
	docker run -it --rm -p '127.0.0.1:50022:22' \
		paracamplus/aestxyz_base /bin/bash
start.aestxyz-base :
	docker run -d -p '127.0.0.1:50022:22' paracamplus/aestxyz_base \
	    sleep $$(( 60 * 60 * 24 * 365 * 10 ))


# end of Makefile
