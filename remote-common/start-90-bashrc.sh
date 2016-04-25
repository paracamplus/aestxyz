#! /bin/bash
# Runs in the container at boot-time as root

echo Patching /root/.bashrc
touch /root/.bashrc
if ! grep -q 'export EDITOR=emacs23' < /root/.bashrc
then {
        #echo 'alias emacs emacs23'
        echo 'export EDITOR=emacs23'
        echo 'export TERM=vt100' 
    } >> /root/.bashrc
fi

# end of start-90-bashrc.sh
