#! /bin/bash
# Runs as root in the Docker container, install private keys to communicate
# with the Marking Slave. 

mkdir -p /home/fw4ex/.ssh
    
# Get private key to ssh the vmms container for user fw4ex:
rsync -au /root/.ssh/ /home/fw4ex/.ssh/

# Fix ownership
chown -R fw4ex: /home/fw4ex/.ssh/

# end of start-41-moveMSkeys.sh
