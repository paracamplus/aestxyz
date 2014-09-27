#! /bin/bash
# Generate new private and public keys

TODIR=${ROOTDIR:-/missing/root.d}/opt/$HOSTNAME
mkdir -p $TODIR
(
    cd $TODIR
    ssh-keygen -t rsa -N '' -b 2048 \
	-C "fw4exCookie@$$HOSTNAME" \
	-f ./fw4excookie
    mv fw4excookie.pub fw4excookie.public.key
    mv fw4excookie     fw4excookie.insecure.key
)

# end of prepare-10.sh
