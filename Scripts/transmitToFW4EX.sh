#! /bin/bash
# Finalize the deployment (see deploy.vmmdr+vmms.on.remote in Docker/Makefile)

rsync -avu Docker/Scripts/transmitToFW4EX.mkf Docker/Makefile

mkdir -p /home/fw4ex/Docker/
rsync -avu Docker/{Makefile,Scripts} /home/fw4ex/Docker/
chown -R fw4ex: /home/fw4ex/Docker/

# end of transmitToFW4EX.sh
