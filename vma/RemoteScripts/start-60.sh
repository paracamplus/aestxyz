#! /bin/bash
# Also start sshd in order to introspect the container with ssh.

if ! /etc/init.d/ssh start
then 
    echo "Cannot start sshd"
    exit 44
fi

# end of start-60.sh
