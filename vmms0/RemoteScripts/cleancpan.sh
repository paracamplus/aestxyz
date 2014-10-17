#! /bin/bash
# Runs as root within the VM.
# /root/RemoteScripts/ contains this script and additional ones.

cd /root/.cpan/ 
touch build/SOMETHING
rm -rf build/* sources/authors/id/
rm -f /tmp/cpan_install*
# Clean also some rubbish in /tmp/ left by cpan tests
rm -rf /tmp/*
rm -rf /tmp/.UUID_*

# end of cleancpan.sh
