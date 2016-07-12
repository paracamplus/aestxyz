#! /bin/bash

# Remove other Apache configuration files. Configurations with the
# domain paracamplus.net are used for test.
(
    cd /etc/apache2/sites-enabled/
    rm -f *.paracamplus.net
)

# Delay some tasks of cron. Otherwise all containers start them at
# the same second causing a CPU peak on the Docker host.
(
    cd /etc/cron.daily/
    # apache2  apt  aptitude  dpkg  exim4-base  logrotate  ntp  passwd
    for f in *
    do
        if ! grep -Fq 'sleep $(( $$ % 59 ))' < $f
        then
            sed -i.bak -e '1asleep $(( $$ % 59 ))' $f
            rm $f.bak
        fi
    done
)

# end of setup-40.sh
