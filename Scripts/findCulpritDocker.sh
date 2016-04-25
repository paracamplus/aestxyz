#! /bin/bash
# Given a PID, find which docker is responsible.
# Should be run as root

PID=$1

cd

docker ps | awk '!/^CONTAINER/ {print $NF}' | \
while read name
do
    if docker top $name | awk "\$2 == $PID { print \"$name\" ; exit(0) } END { exit(1) }"
    then
        echo "Container containing $PID is $name" 1>&2
        case "$name" in 
            vm?)
                Docker/${name#vm}.paracamplus.com/install.sh
                ;;
            mooc-*)
                Docker/${name}.paracamplus.com/install.sh
                ;;
        esac
    fi
done

# end of findCulpritDocker.sh
