#! /bin/bash
# Patch Google::Chart
# Useless when using a more modern js library!

(
    # Patch Google::Chart
    cd /usr/local/share/perl/5.*/
    if [ -f Google/Chart.pm ]
    then
        cd Google/
        sed -i -e '66s/1,/0,/' Chart.pm
    fi
)

# end of setup-05-patchGoogleChart.sh
