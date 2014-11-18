#! /bin/bash
# Specific version for Marking Driver

cd /root/
#echo "Fixing rights on fw4exrootlib"
#chmod -R 555 /root/fw4exrootlib/

if ! grep -q ':FW4EX user:' < /etc/passwd
then
    echo "Creating user fw4ex"
    adduser --quiet --shell /bin/bash \
        --disabled-password \
        --gecos "FW4EX user" \
        fw4ex
fi
chown -R fw4ex: /home/fw4ex

# HOSTTYPE is not exported in vmms. This is useful to test utilities.
export HOSTTYPE=$HOSTTYPE

if [ -d /home/fw4ex/C ]
then 
    echo "Compiling C utilities"
    for d in Confiner Transcoder
    do
        echo "Compiling $d"
        rm -rf /home/fw4ex/C/$d/bin
        cd /home/fw4ex/C/$d/ && make | tee /tmp/$d.log
        if grep -q SUCCESSFUL < /tmp/$d.log
        then
            rm -f /tmp/$d.log
            cp -p /home/fw4ex/C/*/bin/*/{confine,transcode} /home/fw4ex/bin/
        else
            echo "Problem compiling $d"
            exit 25
        fi
    done
    rm -rf /home/fw4ex/C
fi

# end of setup-31-fw4exUser.sh
