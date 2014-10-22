#! /bin/bash
# Forbid a Marking Slave to reach Internet. 
# Allow only incoming ssh connexions.

# NOTA: There is no iptables mechanism specific to the container, the
# iptables rules, if any, should be specified on the Docker host. It
# seems that there might be an option --iptables=true 

PATH=/sbin:/bin:/usr/sbin:/usr/bin
NAME="fw4ex-iptables"
DESC="FW4EX VM firewall"
IPTABLES=/sbin/iptables

if ! [ -x $IPTABLES ]
then
    echo "No iptables here!!!!!!!!!!!!!!!!!!!"
    exit
fi

status() {
    $IPTABLES --line-numbers --list -v
}

default_policy() {
    for chain in INPUT OUTPUT FORWARD
    do 
      $IPTABLES -P $chain $1
    done
}

flush() {
    $IPTABLES --flush 
    $IPTABLES --delete-chain
} 

local_ok() {
    $IPTABLES -A INPUT  -i lo -j ACCEPT
    $IPTABLES -A OUTPUT -o lo -j ACCEPT
}

ssh_ok() {
    # on repond aux connexions entrantes ssh
    $IPTABLES -A INPUT -p tcp -m state --state NEW,ESTABLISHED \
        --dport 22 -j ACCEPT
    $IPTABLES -A OUTPUT -p tcp -m state --state ESTABLISHED \
        --sport 22 -j ACCEPT
}

# dns_ok() {
#     # connexion possible aux seuls serveurs DNS 
#     for dns in $IP_DNS
#     do
#         $IPTABLES -A OUTPUT -p udp --dport 53 --destination $dns -j ACCEPT
#         $IPTABLES -A INPUT -p udp -m state --state RELATED,ESTABLISHED \
#             --sport 53 --source $dns -j ACCEPT
#     done
# }

# dhcp_ok() {
#     # On peut demander et recevoir un DHCP
#     $IPTABLES -A INPUT -p udp --dport 67 -j ACCEPT
#     $IPTABLES -A INPUT -p udp -m state --state RELATED,ESTABLISHED \
#         --sport 67 -j ACCEPT
# }

anti_spoof() {
    for source in \
        0.0.0.0/8 \
        127.0.0.0/8 \
        192.168.0.0/16 \
        10.0.0.0/8 
    do
      $IPTABLES -A INPUT -s $source -j LOG --log-prefix "Spoof IP "
      $IPTABLES -A INPUT -s $source -j DROP
    done
}

inbound_filter() {
    $IPTABLES -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    $IPTABLES -A INPUT -j LOG --log-prefix "Dropped(in)! "
    $IPTABLES -A INPUT -j DROP
}

outbound_filter() {
    $IPTABLES -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    $IPTABLES -A OUTPUT -j LOG --log-prefix "Dropped(out)! "
    $IPTABLES -A OUTPUT -j DROP
}

forward_filter() {
    $IPTABLES -A FORWARD -j LOG --log-prefix "Dropped(forward)! " 
    $IPTABLES -A FORWARD -j DROP
}

start () {
    if flush 
    then
        default_policy DROP && \
        local_ok && \
        ssh_ok && \
        anti_spoof && \
        inbound_filter && \
        forward_filter && \
        outbound_filter
        #dns_ok
        #dhcp_ok
        true
    else
        echo "Cannot set iptables in the Marking Slave"
    fi
}

start

# end of start-15-iptables.sh
