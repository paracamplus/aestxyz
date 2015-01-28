#! /bin/bash
# Stop starman

# Look for the master:
M=$(ps axo pid,cmd | grep 'starman master' | grep -v grep | awk '{print $1}')
if [ -n "$M" ]
then
    echo "Kill Starman master $M" 1>&2
    kill -9 $M
fi

# Kill the associated workers:
ps axo pid,cmd | grep 'starman ' | grep -v grep | while read pid cmd
do
    echo "Kill Starman worker $pid" 1>&2
    kill -9 $pid
done

# wait until all workers are gone
while true
do
    W=$(ps axo pid,cmd | grep 'starman ' | grep -v grep | wc -l)
    echo "Wait for $W Starman workers death..." 1>&2 
    if [ "$W" -eq 0 ]
    then
        exit
    else
        sleep 1
    fi
done

# end of starman-stop.sh
