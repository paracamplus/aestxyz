#! /bin/bash
# Also start sshd in order to introspect the container with ssh.

for f in /etc/ssh/ssh*_config
do
    sed -i.bak \
        -e 's/^# *GSSAPIAuthentication no/GSSAPIAuthentication no/' \
        -e '/GSSAPIAuthentication *yes/d' \
        $f
done

if ! /etc/init.d/ssh start
then 
    echo "Cannot start sshd"
    exit 44
fi

# end of start-60.sh
