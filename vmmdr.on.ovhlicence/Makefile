work : deploy
clean :: cleanMakefile

deploy : 
	-rm -f vmmdr+vmms.tgz
	m vmmdr+vmms.tgz install.on.ovhlicence

rebuild.vmmdr+vmms.tgz :
	-rm -f vmmdr+vmms.tgz
	m vmmdr+vmms.tgz 

vmmdr+vmms.tgz :
	tar chzf vmmdr+vmms.tgz \
		monitor.sh \
		Makefile \
		vmms.paracamplus.com/*.sh \
		vmms.paracamplus.com/fw4ex* \
		vmms.paracamplus.com/keys.t* \
		vmms.paracamplus.com/saver* \
		vmmdr.paracamplus.com/*.sh \
		vmmdr.paracamplus.com/fw4ex* \
		vmmdr.paracamplus.com/keys.t* \
		vmmdr.paracamplus.com/saver* 
	cp -p vmmdr+vmms.tgz $$(date -u +vmmdr+vmms-%FT%H%M%S.tgz)

REMOTE	=	ns353482.ovh.net
install.on.REMOTE.as.fw4ex :
	ssh fw4ex@${REMOTE} "mkdir -p Docker"
	rsync -avu vmmdr+vmms.tgz fw4ex@${REMOTE}':'Docker/
	ssh fw4ex@${REMOTE} \
		"cd Docker/ && tar xzf vmmdr+vmms.tgz --overwrite "

install.on.ovhlicence : 
	m install.on.REMOTE.as.fw4ex REMOTE=ns353482.ovh.net

install.on.kimsufi : 
	m install.on.REMOTE.as.fw4ex REMOTE=ns327071.ovh.net

MYDOCKERDIR=Paracamplus/ExerciseFrameWork/Docker
install.on.ovhlicence : install.on.ovhlicence.as.me
install.on.ovhlicence.as.me :
	rsync -avu vmmdr+vmms.tgz \
		ns353482.ovh.net':'${MYDOCKERDIR}/vmmdr.on.ovhlicence/
	ssh ns353482.ovh.net "cd ${MYDOCKERDIR}/vmmdr.on.ovhlicence/ && \
		tar xzf vmmdr+vmms.tgz --overwrite "

# ##################################### To be done on the remote machine:
run.on.ovhlicence :
	tar xzf vmmdr+vmms.tgz --overwrite

# end of Makefile
