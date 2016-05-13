#! /bin/bash
# Runs in the container at boot-time as root
# NOTA: the /root/ directory seems to have special features.

echo Patching /root/.bashrc
touch /root/.bashrc
if ! grep -q 'export EDITOR=emacs23' < /root/.bashrc
then {
        #echo 'alias emacs emacs23' >> /root/.bashrc
        echo 'export EDITOR=emacs23' 
        echo 'export TERM=vt100' 
    } >> /root/.bashrc
fi

true

# end of start-90-bashrc.sh
