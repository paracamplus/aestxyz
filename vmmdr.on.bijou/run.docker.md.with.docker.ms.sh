#! /bin/bash
# Runs on Bijou, starts one container with a Marking Driver and another
# one with a Marking Slave. These two containers use specific config.sh

# Initially, we are in the directory holding monitor.sh.
# Goto the directory holding vmm[sd].paracamplus.com/ sub-directories
cd ${0%/*}/../

vmms.paracamplus.com/install.sh
CODE=$?
[ "$CODE" -ne 0 ] && exit $CODE

vmmdr.paracamplus.com/install.sh
CODE=$?
[ "$CODE" -ne 0 ] && exit $CODE

# Show MD log:
tail -F /var/log/fw4ex/mdr/md/md.log

# end of run.docker.md.with.docker.ms.sh
