#! /bin/bash
# Let a0.paracamplus.com be the same as a.paracamplus.com

(
    cd /var/www/
    rmdir a0.paracamplus.com
    if [ -d a0.paracamplus.com ]
    then
        echo "/var/www/a0.paracamplus.com not empty ?"
        exit 51
    fi
    ln -s a.paracamplus.com a0.paracamplus.com
)

# end of check-06-hack-a0varwww.sh
