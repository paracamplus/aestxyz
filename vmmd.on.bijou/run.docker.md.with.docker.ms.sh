#! /bin/bash
# Runs on Bijou, starts one container with a Marking Driver and another
# one with a Marking Slave.

# Goto the directory holding vmm[sd].paracamplus.com/ sub-directories
cd ${0%/*}/../

vmms.paracamplus.com/install.sh -s 300 #DEBUG

vmmdr.paracamplus.com/install.sh -s 300

# Show MD log:
ssh -i vmmdr.paracamplus.com/root_rsa \
    -p 61022 \
    root@127.0.0.1 \
    tail -F /var/log/fw4ex/md/md.log

# end of run.docker.md.with.docker.ms.sh
