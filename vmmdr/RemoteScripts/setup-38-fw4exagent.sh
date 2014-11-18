#! /bin/bash
# Runs as root in the Marking Slave container. Install FW4EX agent

( 
    cd /tmp
    tar xzf /opt/TGZ/FW4EX-Agent-latest.tar.gz
    trap "rm -rf /tmp/FW4EX-Agent-*/" 0
    cd FW4EX-Agent-*/
    perl Makefile.PL && make install
    
    # This should be done in the previous install!
    cp -p script/fw4ex-agent.pl /usr/local/bin/
    
    if /usr/local/bin/fw4ex-agent.pl -h 2>&1 | \
        grep -q 'Display what the agent does'
    then :
    else
        echo "fw4ex-agent.pl not installed"
        exit 24
    fi
)

# end of setup-38-fw4exagent.sh
