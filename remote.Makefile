# Restart all containers                                                        

restart.all :
	for m in a e li314 mooc-li101-2014fev t x y z ; \
	do $$m.paracamplus.com/install.sh ;\
	done
# Don't restart a6.                                                             

refresh.all :
	for m in vma vme li314 mooc-li101-2014fev \
                 vmt vmx vmy vmz vmms vmmdr ;\
	do docker pull paracamplus/aestxyz_$$m ;\
	done

restart.vmmdr+vmms.with.log :
	echo "Docker/monitor.sh start -l" | su - fw4ex

# end
