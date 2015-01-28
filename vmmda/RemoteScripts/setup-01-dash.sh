#! /bin/bash
# Restaure sh to be bash and not dash

(cd /bin ; ln -sf bash dash)

#cat /etc/locale.gen  #DEBUG
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
locale -a

# end of setup-01-dash.sh
