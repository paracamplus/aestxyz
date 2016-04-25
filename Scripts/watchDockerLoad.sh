#! /bin/bash
# A Starman with a %CPU greater than 10% is suspect. Restart it!

export LANG=C

THRESHOLD=${1:-0.5}

TEMP=$(mktemp)
trap "rm -f $TEMP" 0

cd

ps -eo pid,pcpu,cmd | \
  awk "\$3 ~ /^starman/ && \$2 >= ${THRESHOLD} { print \$1, \$NF }" |\
  sed -re 's#^.*/([^/]+)/server.psgi.*$#\1#' | \
  uniq |\
while read innerhost
do
    echo "Should restart Docker container $innerhost" 
    #/root/Docker/$host/install.sh
done

# end of watchDockerLoad.sh
