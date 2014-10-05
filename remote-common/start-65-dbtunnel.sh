#! /bin/bash
# ssh-keygen -t ecdsa -N '' -b 521 -C "dbuser@paracamplus.com" -f dbuser_ecdsa

mkdir -p /root/.ssh
touch /root/.ssh/known_hosts
if ! grep -q 'db.paracamplus.com' < /root/.ssh/known_hosts
then
    cat >>/root/.ssh/known_hosts <<EOF
db.paracamplus.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzcR6m0oqAcjmetHswKMaumD3Bp4cf63svOYVc4sxE/TC0cV4DJ0XBZNHwekzF8nTL+gaj63VFNzvNkuWQvmQBGKbN2lXKfKlNmOhpBuIfVHuqWx+Q0R9BoATV841+JA/LZrfR2NmWDQ9k7G8ieQ9tKeH5YU54wfv+XcF1vUAhTJpttVa6vkicfxgCx6/C0BGa7iYMSp0yW2qt0HikoelfZmCLGaXo9DBfvWcSuSyMBZxHV8qk97GD3YxrlPDG08gSWnldHh9Lp1y2Obd5CSC23z7ZzUd4jD6g8x5G4OCkkDJpTKSQPtvM8L1SUvWZJsT15sMS6sReCYHlgkBUHaOWQ==
EOF
fi

chmod 400 /opt/x.paracamplus.com/private/dbuser_ecdsa

if ssh -i /opt/x.paracamplus.com/private/dbuser_ecdsa \
    dbuser@db.paracamplus.com hostname
then
    if ! ssh -n -N -C -o TCPKeepAlive=yes \
        -i /opt/x.paracamplus.com/private/dbuser_ecdsa \
        -L 5432:127.0.0.1:5432 dbuser@db.paracamplus.com    
    then 
        echo "Cannot create a tunnel towards db.paracamplus.com"
        exit 46
    fi &
else 
    echo "Cannot ssh towards db.paracamplus.com"
    exit 45
fi

# end of start-65-dbtunnel.sh
